package cmd

import (
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"runtime"
	"sort"
	"strconv"
	"sync"
	"time"

	"golang.org/x/text/encoding/japanese"
	"golang.org/x/text/transform"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"github.com/yukimemi/core"
)

//go:generate go-bindata -pkg cmd excelgraph.ps1

const (
	// DateCol is Date column number.
	DateCol = 0
)

const (
	// ExitOK is exit code on success.
	ExitOK int = iota
	// ExitNG is exit code on error.
	ExitNG
)

var (
	// OutCsv is csv output path.
	OutCsv string
	// OutExcel is excel output path.
	OutExcel string

	// AverageCnt output count.
	AverageCnt int
	// MedianCnt output count.
	MedianCnt int
	// ModeCnt output count.
	ModeCnt int
	// RangeCnt output count.
	RangeCnt int
	// MaxCnt output count.
	MaxCnt int
	// VarianceCnt output count.
	VarianceCnt int

	// RmCsv is whether remove output csv.
	RmCsv bool

	// Begin is begin of data range. (HHMMSS)
	Begin     string
	beginTime *time.Time

	// End is end of data range. (HHMMSS)
	End     string
	endTime *time.Time

	// Match is regexp target performance name.
	Match   string
	matchRe *regexp.Regexp
	// Ignore is regexp ignore target performance name.
	Ignore   string
	ignoreRe *regexp.Regexp

	// Ymax is chart max value.
	Ymax int64
	// Ymin is chart min value.
	Ymin int64

	// rowCnt is data row count.
	rowCnt int64

	// DateTimeVec is DateTime vector.
	DateTimeVec = make([]string, 0)

	cfgFile string
)

// Perfs is Perf slice.
type Perfs []Perf

// Perf is performance data.
type Perf struct {
	Name string
	Data []DataRow

	Sum      float64
	Average  float64
	Median   float64
	Mode     float64
	Range    float64
	Max      float64
	Variance float64
}

// DataRow is data record.
type DataRow struct {
	DateTime string
	Data     float64
}

// RootCmd represents the base command when called without any subcommands
var RootCmd = &cobra.Command{
	Use:   "anaperf path/to/mcodir",
	Short: "Analyze performance data.",
	Long: `Analyze performance csv data
For example:

	anaperf path/to/perfdata.csv

`,
	RunE: runE,
}

// Execute adds all child commands to the root command sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	if err := RootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(ExitNG)
	}
}

func init() {
	cobra.OnInitialize(initConfig)

	// log setting.
	log.SetFlags(log.Lshortfile)

	// Get pwd.
	pwd, err := os.Getwd()
	core.FailOnError(err)

	// Output path.
	nowTime := time.Now().Format("20060102-150405.000")
	outCsvPath := filepath.Join(pwd, nowTime+".csv")
	outExcelPath := filepath.Join(pwd, nowTime+".xlsx")
	RootCmd.PersistentFlags().StringVarP(&OutCsv, "csv", "c", outCsvPath, "Output csv path")
	RootCmd.PersistentFlags().StringVarP(&OutExcel, "excel", "e", outExcelPath, "Output excel path")

	// Top performance data count.
	RootCmd.PersistentFlags().IntVar(&AverageCnt, "average", 10, "Top count on average data")
	RootCmd.PersistentFlags().IntVar(&MedianCnt, "median", 10, "Top count on median data")
	// RootCmd.PersistentFlags().IntVar(&ModeCnt, "mode", 10, "Top count on mode data") TODO:
	RootCmd.PersistentFlags().IntVar(&RangeCnt, "range", 10, "Top count on range data")
	RootCmd.PersistentFlags().IntVar(&MaxCnt, "max", 10, "Top count on max data")
	// RootCmd.PersistentFlags().IntVar(&VarianceCnt, "variance", 10, "Top count on variance data") TODO:

	// Begin and end option.
	RootCmd.PersistentFlags().StringVar(&Begin, "begin", "", "Begin of data range")
	RootCmd.PersistentFlags().StringVar(&End, "end", "", "End of data range")

	// Remove csv option.
	RootCmd.PersistentFlags().BoolVar(&RmCsv, "rmcsv", false, "Remove csv file")

	// regexp option.
	RootCmd.PersistentFlags().StringVar(&Match, "match", ".*", "Match counter name (regexp)")
	RootCmd.PersistentFlags().StringVar(&Ignore, "ignore", "", "Ignore counter name (regexp)")

	// Chart option.
	RootCmd.PersistentFlags().Int64Var(&Ymax, "ymax", 0, "Chart max value")
	RootCmd.PersistentFlags().Int64Var(&Ymin, "ymin", 0, "Chart min value")
}

// initConfig reads in config file and ENV variables if set.
func initConfig() {

	if cfgFile != "" {
		viper.SetConfigFile(cfgFile)
	}

	viper.SetConfigName(".anaperf")
	viper.AddConfigPath("$HOME")
	viper.AddConfigPath(".")
	viper.AutomaticEnv()

	// If a config file is found, read it in.
	if err := viper.ReadInConfig(); err == nil {
		fmt.Println("Using config file:", viper.ConfigFileUsed())
	}
}

func readCsv(csvFile string) (Perfs, error) {

	file, err := os.Open(csvFile)
	if err != nil {
		return Perfs{}, err
	}
	defer file.Close()
	reader := csv.NewReader(transform.NewReader(file, japanese.ShiftJIS.NewDecoder()))
	reader.FieldsPerRecord = -1

	perfs := make(Perfs, 0)
	row := 0

	for {
		r, err := reader.Read()
		if err == io.EOF {
			break
		}
		if len(r) < 1 {
			return Perfs{}, fmt.Errorf("[%v] is not perf file. column len: [%v]", csvFile, len(r))
		}

		row++

		dateTime := ""
		if row != 1 {
			dateTime = r[0]
			if beginTime != nil || endTime != nil {
				dt, err := time.Parse("01/02/2006 15:04:05.000", dateTime)
				if err != nil {
					return Perfs{}, err
				}
				if beginTime != nil {
					if getNanosecond(dt) < getNanosecond(*beginTime) {
						continue
					}
				}
				if endTime != nil {
					if getNanosecond(dt) > getNanosecond(*endTime) {
						continue
					}
				}
			}
			DateTimeVec = append(DateTimeVec, dateTime)
		}

		rowCnt++
		fmt.Fprintf(os.Stderr, "Row count: %d\r", rowCnt)

		for col, data := range r {
			if row == 1 {
				// Get header.
				if col != 0 {
					perfs = append(perfs, Perf{Name: data, Data: make([]DataRow, 0)})
				}
				continue
			}
			if col != 0 {
				// Get data.
				data, err := strconv.ParseFloat(data, 64)
				if err != nil {
					data = 0.0
				}
				perfs[col-1].Data = append(perfs[col-1].Data, DataRow{
					DateTime: dateTime,
					Data:     data,
				})
			}
		}
	}

	return perfs, nil
}

func analyze(perfs Perfs) (chan Perf, error) {

	wg := new(sync.WaitGroup)
	q := make(chan Perf, 20)
	sem := make(chan struct{}, runtime.NumCPU())

	for _, perf := range perfs {
		wg.Add(1)
		go func(perf Perf) {
			sem <- struct{}{}
			defer func() {
				wg.Done()
				<-sem
			}()

			if !matchRe.MatchString(perf.Name) {
				return
			}
			if ignoreRe != nil {
				if ignoreRe.MatchString(perf.Name) {
					return
				}
			}

			for _, dataRow := range perf.Data {
				perf.Sum += dataRow.Data
				if perf.Max < dataRow.Data {
					perf.Max = dataRow.Data
				}
			}

			perf.Average = perf.Sum / float64(len(perf.Data))

			sortData := make([]DataRow, len(perf.Data))
			copy(sortData, perf.Data)
			sort.Slice(sortData, func(i, j int) bool {
				return sortData[i].Data < sortData[j].Data
			})

			perf.Median = sortData[int(len(sortData)/2)].Data

			perf.Range = sortData[len(sortData)-1].Data - sortData[0].Data

			q <- perf
		}(perf)
	}

	// Async wait.
	go func() {
		wg.Wait()
		close(q)
	}()

	return q, nil
}

func addPerf(perfs Perfs, perf Perf) Perfs {

	for _, added := range perfs {
		if added.Name == perf.Name {
			return perfs
		}
	}

	return append(perfs, perf)
}

func runE(cmd *cobra.Command, args []string) error {

	// Get glob file args.
	args, err := core.GetGlobArgs(args)
	if err != nil {
		return err
	}

	if len(args) != 1 {
		cmd.Help()
		os.Exit(ExitNG)
	}

	// Compile target filter option.
	matchRe, err = regexp.Compile(Match)
	if err != nil {
		return err
	}
	if Ignore != "" {
		ignoreRe, err = regexp.Compile(Ignore)
		if err != nil {
			return err
		}
	}

	// Parse begin and end time
	if Begin != "" {
		beginTime = new(time.Time)
		*beginTime, err = time.Parse("150405", Begin)
		if err != nil {
			return err
		}
	}
	if End != "" {
		endTime = new(time.Time)
		*endTime, err = time.Parse("150405", End)
		if err != nil {
			return err
		}
	}

	// Get data and store.
	perfs, err := readCsv(args[0])
	if err != nil {
		return err
	}

	// Analyze perfs.
	q, err := analyze(perfs)
	if err != nil {
		return err
	}

	perfs = Perfs{}
	for perf := range q {
		perfs = append(perfs, perf)
	}

	anaPerfs := Perfs{}

	// Get only MaxCnt data.
	if len(perfs) < MaxCnt {
		MaxCnt = len(perfs)
	} else {
		// Max sort.
		sort.Slice(perfs, func(i, j int) bool {
			return perfs[i].Max > perfs[j].Max
		})
	}
	for _, perf := range perfs[0:MaxCnt] {
		anaPerfs = addPerf(anaPerfs, perf)
	}

	// Get only AverageCnt data.
	if len(perfs) < AverageCnt {
		AverageCnt = len(perfs)
	} else {
		// Average sort.
		sort.Slice(perfs, func(i, j int) bool {
			return perfs[i].Average > perfs[j].Average
		})
	}
	for _, perf := range perfs[0:AverageCnt] {
		anaPerfs = addPerf(anaPerfs, perf)
	}

	// Get only Median data.
	if len(perfs) < MedianCnt {
		MedianCnt = len(perfs)
	} else {
		// Average sort.
		sort.Slice(perfs, func(i, j int) bool {
			return perfs[i].Median > perfs[j].Median
		})
	}
	for _, perf := range perfs[0:MedianCnt] {
		anaPerfs = addPerf(anaPerfs, perf)
	}

	// Get only Range data.
	if len(perfs) < RangeCnt {
		RangeCnt = len(perfs)
	} else {
		// Max sort.
		sort.Slice(perfs, func(i, j int) bool {
			return perfs[i].Range > perfs[j].Range
		})
	}
	for _, perf := range perfs[0:RangeCnt] {
		anaPerfs = addPerf(anaPerfs, perf)
	}

	// Change format to csv array.
	header := []string{"DateTime"}
	for _, perf := range anaPerfs {
		header = append(header, perf.Name)
	}

	csvArray := make([][]string, rowCnt)
	for row := range csvArray {
		csvArray[row] = make([]string, len(anaPerfs)+1)
		if row == 0 {
			csvArray[row] = header
		} else {
			// Add DateTime.
			csvArray[row][0] = DateTimeVec[row-1]

			// Add performance data.
			for col, perf := range anaPerfs {
				csvArray[row][col+1] = fmt.Sprint(perf.Data[row-1].Data)
			}
		}
	}

	// Output to csv.
	os.MkdirAll(filepath.Dir(OutCsv), os.ModePerm)
	c, err := os.Create(OutCsv)
	if err != nil {
		return err
	}
	defer c.Close()
	writer := csv.NewWriter(transform.NewWriter(c, japanese.ShiftJIS.NewEncoder()))
	writer.UseCRLF = true

	// Write.
	err = writer.WriteAll(csvArray)
	if err != nil {
		return err
	}
	writer.Flush()
	fmt.Printf("Write to [%s]. ([%d] line)\n", OutCsv, rowCnt)

	// Print.
	fmt.Printf("%100v %25v %25v %25v %25v\n", "Name", "Average", "Max", "Median", "Range")
	for _, perf := range anaPerfs {
		fmt.Printf("%100v %25v %25v %25v %25v\n", perf.Name, perf.Average, perf.Max, perf.Median, perf.Range)
	}

	// Output to excel.
	bin, err := Asset("excelgraph.ps1")
	if err != nil {
		return err
	}

	pwd, err := os.Getwd()
	if err != nil {
		return err
	}

	err = os.Setenv("scriptPath", filepath.Join(pwd, "excelgraph"))
	if err != nil {
		return err
	}

	var command core.Cmd

	if Ymax != 0 && Ymin != 0 {
		command = core.Cmd{Cmd: exec.Command(
			"powershell",
			"-Command",
			"& (iex '{"+string(bin)+"}')",
			OutCsv,
			OutExcel,
			fmt.Sprint(Ymax),
			fmt.Sprint(Ymin),
		)}
	} else if Ymax != 0 {
		command = core.Cmd{Cmd: exec.Command(
			"powershell",
			"-Command",
			"& (iex '{"+string(bin)+"}')",
			OutCsv,
			OutExcel,
			fmt.Sprint(Ymax),
		)}
	} else if Ymin != 0 {
		command = core.Cmd{Cmd: exec.Command(
			"powershell",
			"-Command",
			"& (iex '{"+string(bin)+"}')",
			OutCsv,
			OutExcel,
			"-min",
			fmt.Sprint(Ymin),
		)}
	} else {
		command = core.Cmd{Cmd: exec.Command(
			"powershell",
			"-Command",
			"& (iex '{"+string(bin)+"}')",
			OutCsv,
			OutExcel,
		)}
	}

	command.StdoutPrint = true
	command.StderrPrint = true

	// Change encode to ShiftJIS.
	command.StdoutEnc = japanese.ShiftJIS.NewDecoder()
	command.StderrEnc = japanese.ShiftJIS.NewDecoder()

	// Start command.
	core.FailOnError(command.CmdRun())

	// Remove csv files.
	if RmCsv {
		c.Close()
		fmt.Printf("Remove: [%v]\n", OutCsv)
		os.Remove(OutCsv)
	}

	return nil
}

func getNanosecond(t time.Time) time.Duration {
	return time.Duration(t.Hour())*time.Hour +
		time.Duration(t.Minute())*time.Minute +
		time.Duration(t.Nanosecond())*time.Nanosecond
}
