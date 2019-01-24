/*
  Copyright (c) 2019, miya
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import java.lang.Math;

public class BootProgram extends AsmLib
{
  private static final int CODE_ROM_WIDTH = 16;
  private static final int DATA_ROM_WIDTH = 32;
  private static final int CODE_ROM_DEPTH = 11;
  private static final int DATA_ROM_DEPTH = 11;

  private static final int PE_CODE_DEPTH = 9;

  public void f_program_loader()
  {
    // input: R3:data_offset R4:data_size
    /*
    addr_reset = MASTER_W_BANK_IO_REG;
    addr_reset <<= DEPTH_B_M_W;
    addr_reset += IO_REG_W_RESET_PE;
    mem[addr_reset] = 1;
    size = R4;
    addr_memi = M2S_BANK_MEM_I;
    addr_memi <<= DEPTH_B_M2S;
    addr_pe = MASTER_W_BANK_BC;
    addr_pe <<= DEPTH_B_M_W;
    addr_pe += addr_memi;
    addr_u2m = MASTER_R_BANK_U2M;
    addr_u2m <<= DEPTH_B_U;
    addr_u2m += R3;
    do
    {
      size -= 1;
      data = mem[addr_u2m];
      mem[addr_pe] = data;
      addr_u2m++;
      addr_pe++;
    } while (size != 0)
    mem[addr_reset] = 0;
    */
    int size = LREG0;
    int addr_pe = LREG1;
    int addr_u2m = LREG2;
    int data = LREG3;
    int addr_memi = LREG4;
    int addr_reset = LREG5;
    label("f_program_loader");
    lib_push(SP_REG_LINK);
    lib_wait_dep_pre();
    as_mvi(addr_reset, MASTER_W_BANK_IO_REG);
    lib_wait_dep_post();
    lib_wait_dep_pre();
    as_sli(addr_reset, DEPTH_B_M_W);
    lib_wait_dep_post();
    lib_wait_dep_pre();
    as_addi(addr_reset, IO_REG_W_RESET_PE);
    lib_wait_dep_post();
    as_sti(addr_reset, 1);
    as_add(size, R4);
    as_mvi(addr_memi, M2S_BANK_MEM_I);
    as_mvi(addr_u2m, MASTER_R_BANK_U2M);
    lib_set_im(addr_pe, MASTER_W_BANK_BC);
    lib_wait_dep_pre();
    as_nop();
    lib_wait_dep_post();
    as_sli(addr_memi, DEPTH_B_M2S);
    as_sli(addr_u2m, DEPTH_B_U);
    lib_wait_dep_pre();
    as_sli(addr_pe, DEPTH_B_M_W);
    lib_wait_dep_post();
    as_add(addr_u2m, R3);
    as_add(addr_pe, addr_memi);
    label("f_program_loader_L_0");
    as_ld(data, addr_u2m);
    as_subi(size, 1);
    as_addi(addr_u2m, 1);
    lib_nop(3);
    as_st(addr_pe, data);
    as_cnz(SP_REG_CP, size);
    as_addi(addr_pe, 1);
    lib_bc("f_program_loader_L_0");
    as_sti(addr_reset, 0);
    lib_pop(SP_REG_LINK);
    lib_return();
  }

  @Override
  public void init()
  {
    set_rom_width(CODE_ROM_WIDTH, DATA_ROM_WIDTH);
    set_rom_depth(CODE_ROM_DEPTH, DATA_ROM_DEPTH);
    set_stack_address((1 << DATA_ROM_DEPTH) - 1);
    set_filename("boot");
  }

  @Override
  public void program()
  {
    // load PE code
    as_nop();
    lib_init_stack();
    as_mvi(R4, 1);
    as_mvi(R3, 0);
    lib_wait_dependency();
    as_sli(R4, PE_CODE_DEPTH);
    lib_call("f_program_loader");
    lib_call("f_halt");
    // link library
    f_halt();
    f_program_loader();
  }

  @Override
  public void data()
  {
    dat(0);
  }
}
