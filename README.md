# ZX-1 流水灯：Neovim + Makefile + Quartus

> 其实这个东西是我个人的探索，quartus那个傻逼gui界面太丑了，，，不过好在，我的探索是成功的，这套流程是对的
> 上传上去只做参考

一个不用 Quartus 图形编辑器的 FPGA 小工程：在 Neovim 中编写 Verilog，用 Makefile 调用 Quartus 编译和 USB-Blaster 下载。当前示例是 **Cyclone IV E EP4CE10F17C8N / ZX-1** 上的三灯流水灯。

> **仅作流程参考**：安装路径、Quartus 版本、器件型号、引脚、时钟频率、配置 Flash 和 USB-Blaster 名称都依赖个人电脑与开发板。移植时请核对板卡原理图和本机环境，修改 `Makefile`、`fpgatest.qsf` 与 `fpgatest.sdc`，不要直接照搬引脚或烧写参数。

## 工程文件

- `fpgatest.v`：顶层 Verilog 程序。
- `fpgatest.qpf`：Quartus 工程修订名。
- `fpgatest.qsf`：器件、源文件、板卡引脚等设置。
- `fpgatest.sdc`：50 MHz 时钟约束（20 ns）。
- `Makefile`：检查、编译、查看报告、下载及固化命令。

`db/`、`incremental_db/`、`output_files/` 是编译生成目录，不纳入 Git。下载前必须在本机编译生成 `.sof`。

## 本机准备

安装支持目标器件的 Quartus Prime（本项目使用 Lite 25.1std）和 USB-Blaster 驱动/udev 权限规则。Makefile 目前假设工具位于 `~/altera_lite/25.1std/quartus/bin`；若路径不同，请修改其中的 `QBIN`、`SFL`。下载前给板子上电，将排线插到板子的 **JTAG** 座，通过 `jtagconfig` 查看可用的线缆名与 FPGA 器件。

当前示例的板载时钟为 50 MHz，`clk` 接 `E1`；三路低电平点亮的 LED 对应 `T12`、`P8`、`M8`。**其他板子应以自己的资料为准。**

## 日常开发步骤

```sh
cd led-flow
nvim fpgatest.v             # 1. 修改程序；也可编辑 .qsf / .sdc
make check                 # 2. 分析与展开，快速发现部分错误
make build                 # 3. 完整编译，生成 output_files/fpgatest.sof
make report                # 4. 查看资源和时序摘要，留意警告及 slack
jtagconfig                 # 5. 板子上电、排线插 JTAG，确认链上的 FPGA
make program               # 6. 通过 JTAG 下载 .sof，断电后失效
```

若线缆名与默认的 `USB-Blaster [1-2]` 不同，使用 `make program CABLE='jtagconfig 显示的名称'`（固化时同理）。`make program` **不会自动编译**，修改源码后先执行 `make build`，以免下载旧的 `.sof`。

## 可选：经 JTAG 固化到配置 Flash

```sh
make flash-jtag
```

此目标按顺序 **重新编译 → 生成 `.jic` → 加载 SFL → 写入配置 Flash**。它会覆盖板上已有的 Flash 配置，务必核对设备、线缆与新生成的程序。本示例使用板载 M25P16（按 EPCS16 配置）和 `sfl_ep4ce10.sof`，只适用于相应的硬件配置；其他板子必须重新核对这些参数。固化完成后，按板卡情况移开下载线或断电重上电，验证脱离下载线能否启动。

## License

MIT，见 [LICENSE](LICENSE)。
