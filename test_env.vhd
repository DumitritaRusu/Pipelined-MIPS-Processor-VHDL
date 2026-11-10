library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port (
        clk : in STD_LOGIC;
        btn : in STD_LOGIC_VECTOR(1 downto 0);
        sw  : in STD_LOGIC_VECTOR(7 downto 0);
        led : out STD_LOGIC_VECTOR(15 downto 0);
        an  : out STD_LOGIC_VECTOR(7 downto 0);
        cat : out STD_LOGIC_VECTOR(6 downto 0)
    );
end test_env;

architecture Behavioral of test_env is

    signal EN, RST : STD_LOGIC;

    -- IF
    signal Instruction_IF, PCPlus4_IF : STD_LOGIC_VECTOR(31 downto 0);
    signal PCSrc : STD_LOGIC;
    signal JumpAddress, BranchAddress_EXMEM : STD_LOGIC_VECTOR(31 downto 0);

    -- IF/ID
    signal Instr_IFID, PCPlus4_IFID : STD_LOGIC_VECTOR(31 downto 0);

    -- UC
    signal RegDst_ID, ExtOp_ID, ALUSrc_ID, Branch_ID, Jump_ID : STD_LOGIC;
    signal MemWrite_ID, MemtoReg_ID, RegWrite_ID : STD_LOGIC;
    signal ALUOp_ID : STD_LOGIC_VECTOR(2 downto 0);

    -- ID
    signal RD1_ID, RD2_ID, ExtImm_ID : STD_LOGIC_VECTOR(31 downto 0);
    signal func_ID : STD_LOGIC_VECTOR(5 downto 0);
    signal sa_ID, rt_ID, rd_ID : STD_LOGIC_VECTOR(4 downto 0);

    -- ID/EX
    signal RD1_IDEX, RD2_IDEX, ExtImm_IDEX, PCPlus4_IDEX : STD_LOGIC_VECTOR(31 downto 0);
    signal func_IDEX : STD_LOGIC_VECTOR(5 downto 0);
    signal sa_IDEX, rt_IDEX, rd_IDEX : STD_LOGIC_VECTOR(4 downto 0);
    signal RegDst_IDEX, ALUSrc_IDEX, Branch_IDEX : STD_LOGIC;
    signal MemWrite_IDEX, MemtoReg_IDEX, RegWrite_IDEX : STD_LOGIC;
    signal ALUOp_IDEX : STD_LOGIC_VECTOR(2 downto 0);

    -- EX
    signal ALURes_EX, BranchAddress_EX : STD_LOGIC_VECTOR(31 downto 0);
    signal Zero_EX : STD_LOGIC;
    signal WA_EX : STD_LOGIC_VECTOR(4 downto 0);

    -- EX/MEM
    signal ALURes_EXMEM, RD2_EXMEM : STD_LOGIC_VECTOR(31 downto 0);
    signal Zero_EXMEM : STD_LOGIC;
    signal WA_EXMEM : STD_LOGIC_VECTOR(4 downto 0);
    signal Branch_EXMEM, MemWrite_EXMEM, MemtoReg_EXMEM, RegWrite_EXMEM : STD_LOGIC;

    -- MEM
    signal MemData_MEM, ALURes_MEM : STD_LOGIC_VECTOR(31 downto 0);

    -- MEM/WB
    signal MemData_MEMWB, ALURes_MEMWB : STD_LOGIC_VECTOR(31 downto 0);
    signal WA_MEMWB : STD_LOGIC_VECTOR(4 downto 0);
    signal MemtoReg_MEMWB, RegWrite_MEMWB : STD_LOGIC;

    -- WB
    signal WD_WB : STD_LOGIC_VECTOR(31 downto 0);

    -- SSD
    signal digits : STD_LOGIC_VECTOR(31 downto 0);

begin

    mpg_en: entity work.MPG
        port map(enable => EN, btn => btn(0), clk => clk);

    mpg_rst: entity work.MPG
        port map(enable => RST, btn => btn(1), clk => clk);

    PCSrc <= Branch_EXMEM and Zero_EXMEM;

    JumpAddress <= PCPlus4_IFID(31 downto 28) & Instr_IFID(25 downto 0) & "00";

    InstructionFetch: entity work.IFetch
        port map(
            clk => clk,
            rst => RST,
            en => EN,
            Jump => Jump_ID,
            PCSrc => PCSrc,
            JumpAddress => JumpAddress,
            BranchAddress => BranchAddress_EXMEM,
            Instruction => Instruction_IF,
            PCPlus4 => PCPlus4_IF
        );

    -- IF/ID
    process(clk)
    begin
        if rising_edge(clk) then
            if RST = '1' then
                Instr_IFID <= (others => '0');
                PCPlus4_IFID <= (others => '0');
            elsif EN = '1' then
                Instr_IFID <= Instruction_IF;
                PCPlus4_IFID <= PCPlus4_IF;
            end if;
        end if;
    end process;

    ControlUnit: entity work.UC
        port map(
            Instr => Instr_IFID(31 downto 26),
            RegDst => RegDst_ID,
            ExtOp => ExtOp_ID,
            ALUSrc => ALUSrc_ID,
            Branch => Branch_ID,
            Jump => Jump_ID,
            ALUOp => ALUOp_ID,
            MemWrite => MemWrite_ID,
            MemtoReg => MemtoReg_ID,
            RegWrite => RegWrite_ID
        );

    InstructionDecode: entity work.ID
        port map(
            clk => clk,
            en => EN,
            RegWrite => RegWrite_MEMWB,
            ExtOp => ExtOp_ID,
            Instr => Instr_IFID(25 downto 0),
            WD => WD_WB,
            WA => WA_MEMWB,
            RD1 => RD1_ID,
            RD2 => RD2_ID,
            Ext_Imm => ExtImm_ID,
            func => func_ID,
            sa => sa_ID,
            rt => rt_ID,
            rd => rd_ID
        );

    -- ID/EX
    process(clk)
    begin
        if rising_edge(clk) then
            if RST = '1' then
                RD1_IDEX <= (others => '0');
                RD2_IDEX <= (others => '0');
                ExtImm_IDEX <= (others => '0');
                PCPlus4_IDEX <= (others => '0');
                func_IDEX <= (others => '0');
                sa_IDEX <= (others => '0');
                rt_IDEX <= (others => '0');
                rd_IDEX <= (others => '0');
                RegDst_IDEX <= '0';
                ALUSrc_IDEX <= '0';
                Branch_IDEX <= '0';
                MemWrite_IDEX <= '0';
                MemtoReg_IDEX <= '0';
                RegWrite_IDEX <= '0';
                ALUOp_IDEX <= (others => '0');
            elsif EN = '1' then
                RD1_IDEX <= RD1_ID;
                RD2_IDEX <= RD2_ID;
                ExtImm_IDEX <= ExtImm_ID;
                PCPlus4_IDEX <= PCPlus4_IFID;
                func_IDEX <= func_ID;
                sa_IDEX <= sa_ID;
                rt_IDEX <= rt_ID;
                rd_IDEX <= rd_ID;
                RegDst_IDEX <= RegDst_ID;
                ALUSrc_IDEX <= ALUSrc_ID;
                Branch_IDEX <= Branch_ID;
                MemWrite_IDEX <= MemWrite_ID;
                MemtoReg_IDEX <= MemtoReg_ID;
                RegWrite_IDEX <= RegWrite_ID;
                ALUOp_IDEX <= ALUOp_ID;
            end if;
        end if;
    end process;

    ExecuteUnit: entity work.EX
        port map(
            RD1 => RD1_IDEX,
            RD2 => RD2_IDEX,
            Ext_Imm => ExtImm_IDEX,
            func => func_IDEX,
            sa => sa_IDEX,
            PCPlus4 => PCPlus4_IDEX,
            ALUSrc => ALUSrc_IDEX,
            ALUOp => ALUOp_IDEX,
            rt => rt_IDEX,
            rd => rd_IDEX,
            RegDst => RegDst_IDEX,
            ALURes => ALURes_EX,
            BranchAddress => BranchAddress_EX,
            Zero => Zero_EX,
            rWA => WA_EX
        );

    -- EX/MEM
    process(clk)
    begin
        if rising_edge(clk) then
            if RST = '1' then
                ALURes_EXMEM <= (others => '0');
                RD2_EXMEM <= (others => '0');
                BranchAddress_EXMEM <= (others => '0');
                Zero_EXMEM <= '0';
                WA_EXMEM <= (others => '0');
                Branch_EXMEM <= '0';
                MemWrite_EXMEM <= '0';
                MemtoReg_EXMEM <= '0';
                RegWrite_EXMEM <= '0';
            elsif EN = '1' then
                ALURes_EXMEM <= ALURes_EX;
                RD2_EXMEM <= RD2_IDEX;
                BranchAddress_EXMEM <= BranchAddress_EX;
                Zero_EXMEM <= Zero_EX;
                WA_EXMEM <= WA_EX;
                Branch_EXMEM <= Branch_IDEX;
                MemWrite_EXMEM <= MemWrite_IDEX;
                MemtoReg_EXMEM <= MemtoReg_IDEX;
                RegWrite_EXMEM <= RegWrite_IDEX;
            end if;
        end if;
    end process;

    MemoryUnit: entity work.MEM
        port map(
            CLK => clk,
            EN => EN,
            MemWrite => MemWrite_EXMEM,
            ALUResIn => ALURes_EXMEM,
            RD2 => RD2_EXMEM,
            MemData => MemData_MEM,
            ALUResOut => ALURes_MEM
        );

    -- MEM/WB
    process(clk)
    begin
        if rising_edge(clk) then
            if RST = '1' then
                MemData_MEMWB <= (others => '0');
                ALURes_MEMWB <= (others => '0');
                WA_MEMWB <= (others => '0');
                MemtoReg_MEMWB <= '0';
                RegWrite_MEMWB <= '0';
            elsif EN = '1' then
                MemData_MEMWB <= MemData_MEM;
                ALURes_MEMWB <= ALURes_MEM;
                WA_MEMWB <= WA_EXMEM;
                MemtoReg_MEMWB <= MemtoReg_EXMEM;
                RegWrite_MEMWB <= RegWrite_EXMEM;
            end if;
        end if;
    end process;

    WD_WB <= MemData_MEMWB when MemtoReg_MEMWB = '1' else ALURes_MEMWB;

    process(sw, Instruction_IF, PCPlus4_IF, RD1_ID, RD2_ID, ExtImm_ID, ALURes_EX, MemData_MEM, WD_WB)
    begin
        case sw(7 downto 5) is
            when "000" => digits <= Instruction_IF;
            when "001" => digits <= PCPlus4_IF;
            when "010" => digits <= RD1_ID;
            when "011" => digits <= RD2_ID;
            when "100" => digits <= ExtImm_ID;
            when "101" => digits <= ALURes_EX;
            when "110" => digits <= MemData_MEM;
            when "111" => digits <= WD_WB;
            when others => digits <= X"00000000";
        end case;
    end process;

    display: entity work.SSD
        port map(
            clk => clk,
            digits => digits,
            an => an,
            cat => cat
        );

    led(10 downto 0) <= ALUOp_ID & RegDst_ID & ExtOp_ID & ALUSrc_ID & Branch_ID & Jump_ID & MemWrite_ID & MemtoReg_ID & RegWrite_ID;
    led(15 downto 11) <= "00000";

end Behavioral;