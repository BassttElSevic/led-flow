// emmm
// god damn i cant using chinese here fxxking fcitx5!
// fxxxxxxxk

// tmd 还是nvim舒服啊

module fpgatest (
    input  wire      clk,
    output reg [2:0] led // 改成3个，这样好验证
);

    reg [24:0] cnt;

    always @(posedge clk) begin
        // 当数到 24,999,999 时（刚好2500万次，约0.5秒）
        if (cnt == 25'd24_999_999) begin
            cnt <= 25'd0;                // 计数器清零
            led <= {led[1:0], led[2]};   // LED 循环左移
        end
        else begin
            cnt <= cnt + 1'b1;           // 否则计数器继续累加
        end
    end

    // 给 LED 赋初值（确保上电时最低位亮）
    // 在 Quartus 中，直接在这里赋初值比在 always 里判断 cnt==0 更靠谱
    initial begin
        led = 3'b1110;
    end
// ：)
endmodule
