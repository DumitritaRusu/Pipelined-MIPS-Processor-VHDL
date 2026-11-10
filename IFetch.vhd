library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
    Port (
        clk           : in  STD_LOGIC;
        rst           : in  STD_LOGIC;
        en            : in  STD_LOGIC;
        Jump          : in  STD_LOGIC;
        PCSrc         : in  STD_LOGIC;
        JumpAddress   : in  STD_LOGIC_VECTOR(31 downto 0);
        BranchAddress : in  STD_LOGIC_VECTOR(31 downto 0);
        Instruction   : out STD_LOGIC_VECTOR(31 downto 0);
        PCPlus4       : out STD_LOGIC_VECTOR(31 downto 0)
    );
end IFetch;

architecture Behavioral of IFetch is

    signal PC       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal PC4      : STD_LOGIC_VECTOR(31 downto 0);
    signal NextPC   : STD_LOGIC_VECTOR(31 downto 0);
    signal MUX1_out : STD_LOGIC_VECTOR(31 downto 0);

    type rom_type is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);

  
    
  signal ROM : rom_type := (
    B"100011_00000_00001_0000000000000100", -- X"8C010004", 00: lw   $1, 4($0)
    B"001000_00000_00010_0000000000001000", -- X"20020008", 01: addi $2, $0, 8
    B"001000_00000_00011_0000000000000000", -- X"20030000", 02: addi $3, $0, 0

    B"001100_00001_00101_0000000000000001", -- X"30250001", 03: andi $5, $1, 1
    X"00000000",                             -- 04: noOp
    X"00000000",                             -- 05: noOp

    B"101011_00010_00101_0000000000000000", -- X"AC450000", 06: sw   $5, 0($2)
    B"100011_00010_00110_0000000000000000", -- X"8C460000", 07: lw   $6, 0($2)

    X"00000000",                             -- 08: noOp
    X"00000000",                             -- 09: noOp

    B"000100_00110_00000_0000000000000100", -- X"10C00004", 10: beq  $6, $0, 4

    X"00000000",                             -- 11: noOp
    X"00000000",                             -- 12: noOp
    X"00000000",                             -- 13: noOp

    B"001000_00011_00011_0000000000000001", -- X"20630001", 14: addi $3, $3, 1
    B"000000_00000_00001_00001_00001_000010", -- X"00010842", 15: srl  $1, $1, 1

    X"00000000",                             -- 16: noOp

    B"001000_00010_00010_0000000000000100", -- X"20420004", 17: addi $2, $2, 4
    B"000100_00001_00000_0000000000000101", -- X"10200005", 18: beq  $1, $0, 5

    X"00000000",                             -- 19: noOp
    X"00000000",                             -- 20: noOp
    X"00000000",                             -- 21: noOp

    B"000010_00000000000000000000000011",   -- X"08000003", 22: j    3

    X"00000000",                             -- 23: noOp

    B"101011_00000_00011_0000000000000000", -- X"AC030000", 24: sw   $3, 0($0)
    B"000010_00000000000000000000011001",   -- X"08000019", 25: j    25

    X"00000000",                             -- 26: noOp

    others => X"00000000"
);

   

begin

    PC4 <= PC + 4;
    PCPlus4 <= PC4;

    MUX1_out <= BranchAddress when PCSrc = '1' else PC4;

    NextPC <= JumpAddress when Jump = '1' else MUX1_out;

    process(clk, rst)
    begin
        if rst = '1' then
            PC <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                PC <= NextPC;
            end if;
        end if;
    end process;

    Instruction <= ROM(conv_integer(PC(6 downto 2)));

end Behavioral;