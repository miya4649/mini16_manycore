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

public class PEProgram extends AsmLib
{
  private static final int CODE_ROM_WIDTH = 16;
  private static final int DATA_ROM_WIDTH = 32;
  private static final int CODE_ROM_DEPTH = 10;
  private static final int DATA_ROM_DEPTH = 8;
  private static final int FIFO_ADDR = (PE_W_BANK_FIFO << DEPTH_B_S_W);
  private static final int VRAM_ADDR_H = ((FIFO_ADDR + (FIFO_BANK_VRAM << DEPTH_B_F)) >>> 15);
  private static final int VRAM_ADDR_SHIFT = 15;
  private static final int M2S_ADDR_H = PE_R_BANK_M2S;
  private static final int M2S_ADDR_SHIFT = DEPTH_B_S_R;
  private static final int S2M_ADDR_H = ((FIFO_ADDR + (FIFO_BANK_S2M << DEPTH_B_F)) >>> 15);
  private static final int S2M_ADDR_SHIFT = 15;
  private static final int IMAGE_WIDTH_BITS = 8;
  private static final int IMAGE_HEIGHT_BITS = 8;
  private static final int IMAGE_WIDTH_HALF_BITS = (IMAGE_WIDTH_BITS - 1);
  private static final int IMAGE_HEIGHT_HALF_BITS = (IMAGE_HEIGHT_BITS - 1);
  private static final int IMAGE_WIDTH = (1 << IMAGE_WIDTH_BITS);
  private static final int IMAGE_HEIGHT = (1 << IMAGE_HEIGHT_BITS);
  private static final int IMAGE_WIDTH_HALF = (1 << IMAGE_WIDTH_HALF_BITS);
  private static final int IMAGE_HEIGHT_HALF = (1 << IMAGE_HEIGHT_HALF_BITS);

  private void m_mandel_core()
  {
    int x = 9;
    int y = 10;
    int scale = 11;
    int count = 12;
    int cx = 13;
    int cy = 14;
    int a = 16;
    int b = 17;
    int aa = 18;
    int bb = 19;
    int c = 20;
    int x1 = 21;
    int y1 = 22;
    int cmask = 23;
    int max_c = 24;
    int pc = 25;
    int tmp1 = 26;
    int tmp2 = 27;
    int tmp3 = 28;

    // const
    int FIXED_BITS = 13;
    int FIXED_BITS_M1 = 12;
    int MAX_C = 4;

    /*
    a = 0;
    b = 0;
    aa = 0;
    bb = 0;
    scale = 256;
    count = 256;
    cmask = 252;
    max_c = MAX_C << FIXED_BITS;
    x1 = ((x - IMAGE_WIDTH_HALF) * scale) + cx;
    y1 = ((y - IMAGE_HEIGHT_HALF) * scale) + cy;
    do
    {
      pc = c;
      b = ((a * b) >> FIXED_BITS_M1) - y1;
      a = aa - bb - x1;
      aa = (a * a) >> FIXED_BITS;
      bb = (b * b) >> FIXED_BITS;
      c = aa + bb;
      count--;
      x1 += scale;
      pc -= c;
      pc >>= 5;
      limit = (c < MAX_C) && (count > 0) && (pc != 0);
    } while (limit);

    as_mvi(a, 0);
    as_mvi(b, 0);
    as_mvi(aa, 0);
    as_mvi(bb, 0);
    as_mv(x1, x);
    as_mv(y1, y);
    lib_set_im(count, 1024);
    lib_set_im(tmp1, IMAGE_WIDTH_HALF);
    lib_set_im(tmp2, IMAGE_HEIGHT_HALF);
    as_mvi(max_c, 4);
    as_sli(max_c, FIXED_BITS);
    as_sub(x1, tmp1);
    as_sub(y1, tmp2);
    as_mul(x1, scale);
    as_mul(y1, scale);
    as_add(x1, cx);
    as_add(y1, cy);
    label("m_mandel_L_0");
    as_mv(pc, c);
    as_mul(b, a);
    as_srai(b, FIXED_BITS_M1);
    as_sub(b, y1);
    as_mv(a, aa);
    as_sub(a, bb);
    as_sub(a, x1);
    as_mv(aa, a);
    as_mul(aa, a);
    as_sri(aa, FIXED_BITS);
    as_mv(bb, b);
    as_mul(bb, b);
    as_sri(bb, FIXED_BITS);
    as_mv(c, aa);
    as_add(c, bb);
    as_subi(count, 1);
    as_add(x1, scale);
    as_mv(tmp1, max_c);
    as_sub(pc, c);
    as_sub(tmp1, c);
    as_sri(pc, 5);
    as_cnm(SP_REG_CP, tmp1);
    as_cnm(tmp2, count);
    as_cnz(tmp3, pc);
    as_and(SP_REG_CP, tmp2);
    as_and(SP_REG_CP, tmp3);
    lib_bc("m_mandel_L_0");
    */

    as_mvi(a, 0);
    as_mvi(b, 0);
    as_mvi(aa, 0);
    as_mvi(bb, 0);
    as_mv(x1, x);
    as_mv(y1, y);
    lib_set_im(count, 100);
    lib_set_im(tmp1, IMAGE_WIDTH_HALF);
    lib_set_im(tmp2, IMAGE_HEIGHT_HALF);
    lib_wait_dep_pre();
    as_mvi(max_c, 4);
    lib_wait_dep_post();
    as_sli(max_c, FIXED_BITS);
    as_sub(x1, tmp1);
    lib_wait_dep_pre();
    as_sub(y1, tmp2);
    lib_wait_dep_post();
    as_mul(x1, scale);
    lib_wait_dep_pre();
    as_mul(y1, scale);
    lib_wait_dep_post();
    as_add(x1, cx);
    as_add(y1, cy);
    label("m_mandel_core_L_0");
    as_mv(pc, c);
    lib_wait_dep_pre();
    as_mul(b, a);
    lib_wait_dep_post();
    lib_wait_dep_pre();
    as_srai(b, FIXED_BITS_M1);
    lib_wait_dep_post();
    as_sub(b, y1);
    lib_wait_dep_pre();
    as_mv(a, aa);
    lib_wait_dep_post();
    lib_wait_dep_pre();
    as_sub(a, bb);
    lib_wait_dep_post();
    lib_wait_dep_pre();
    as_sub(a, x1);
    lib_wait_dep_post();
    lib_wait_dep_pre();
    as_mv(aa, a);
    lib_wait_dep_post();
    lib_wait_dep_pre();
    as_mul(aa, a);
    lib_wait_dep_post();
    as_sri(aa, FIXED_BITS);
    lib_wait_dep_pre();
    as_mv(bb, b);
    lib_wait_dep_post();
    lib_wait_dep_pre();
    as_mul(bb, b);
    lib_wait_dep_post();
    as_sri(bb, FIXED_BITS);
    lib_wait_dep_pre();
    as_mv(c, aa);
    lib_wait_dep_post();
    as_add(c, bb);
    as_subi(count, 1);
    as_add(x1, scale);
    lib_wait_dep_pre();
    as_mv(tmp1, max_c);
    lib_wait_dep_post();
    as_sub(pc, c);
    lib_wait_dep_pre();
    as_sub(tmp1, c);
    lib_wait_dep_post();
    as_sri(pc, 5);
    as_cnm(SP_REG_CP, tmp1);
    lib_wait_dep_pre();
    as_cnm(tmp2, count);
    lib_wait_dep_post();
    as_cnz(tmp3, pc);
    lib_wait_dep_pre();
    as_and(SP_REG_CP, tmp2);
    lib_wait_dep_post();
    as_and(SP_REG_CP, tmp3);
    lib_bc("m_mandel_core_L_0");
  }

  private void m_mandel()
  {
    int my_core_id = 4;
    int parallel = 5;
    int task_id = 6;
    int vram_addr = 7;
    int m2s_addr = 8;
    int page = 8;
    int x = 9;
    int y = 10;
    int scale = 11;
    int count = 12;
    int cx = 13;
    int cy = 14;
    int i = 15;
    // temp
    int tmp0 = 16;
    int param_addr = 16;
    /*
    lib_push_regs(4, 6); // push R4-R9
    get_param;
    page = task_id & 1;
    vram_addr += (page << (IMAGE_WIDTH_BITS + IMAGE_HEIGHT_BITS)) + (1 << (IMAGE_WIDTH_BITS + IMAGE_HEIGHT_BITS)) - 1 - my_core_id;
    i = (1 << (IMAGE_WIDTH_BITS + IMAGE_HEIGHT_BITS)) - 1 - my_core_id;
    do
    {
      x = i & ((1 << IMAGE_WIDTH_BITS) - 1);
      y = i >> IMAGE_WIDTH_BITS;
      m_mandel();
      mem[vram_addr] = count;
      vram_addr -= parallel;
      i -= parallel;
    } while (i >=0);
    lib_pop_regs(4, 6);
    */

    lib_push_regs(4, 6);

    // get param
    lib_wait_dep_pre();
    as_mv(param_addr, m2s_addr);
    lib_wait_dep_post();
    lib_wait_dep_pre();
    as_addi(param_addr, 1);
    lib_wait_dep_post();
    as_ld(scale, param_addr);
    lib_wait_dep_pre();
    as_addi(param_addr, 1);
    lib_wait_dep_post();
    as_ld(cx, param_addr);
    lib_wait_dep_pre();
    as_addi(param_addr, 1);
    lib_wait_dep_post();
    as_ld(cy, param_addr);

    as_mvi(i, 1);
    as_mv(page, task_id);
    as_mvi(tmp0, 1);
    lib_wait_dep_pre();
    as_mvil(IMAGE_WIDTH_BITS + IMAGE_HEIGHT_BITS);
    lib_wait_dep_post();
    as_sl(i, SP_REG_MVIL);
    as_sl(tmp0, SP_REG_MVIL);
    lib_wait_dep_pre();
    as_andi(page, 1);
    lib_wait_dep_post();
    as_subi(i, 1);
    lib_wait_dep_pre();
    as_sl(page, SP_REG_MVIL);
    lib_wait_dep_post();
    as_sub(i, my_core_id);
    lib_wait_dep_pre();
    as_add(page, tmp0);
    lib_wait_dep_post();
    lib_wait_dep_pre();
    as_subi(page, 1);
    lib_wait_dep_post();
    lib_wait_dep_pre();
    as_sub(page, my_core_id);
    lib_wait_dep_post();
    as_add(vram_addr, page);
    label("m_mandel_L_0");
    as_mv(x, i);
    as_mv(y, i);
    lib_set_im(tmp0, (1 << IMAGE_WIDTH_BITS) - 1);
    lib_wait_dep_pre();
    as_sri(y, IMAGE_WIDTH_BITS);
    lib_wait_dep_post();
    lib_wait_dep_pre();
    as_and(x, tmp0);
    lib_wait_dep_post();

    m_mandel_core();

    as_st(vram_addr, count);
    as_sub(vram_addr, parallel);
    lib_wait_dep_pre();
    as_sub(i, parallel);
    lib_wait_dep_post();
    as_cnm(SP_REG_CP, i);
    lib_bc("m_mandel_L_0");
    lib_pop_regs(4, 6);
  }

  private void f_get_m2s_addr()
  {
    // output: R3:m2s_addr
    int m2s_addr = 3;
    // m2s_addr = M2S_ADDR_H << M2S_ADDR_SHIFT;
    label("f_get_m2s_addr");
    lib_wait_dep_pre();
    as_mvi(m2s_addr, M2S_ADDR_H);
    lib_wait_dep_post();
    as_sli(m2s_addr, M2S_ADDR_SHIFT);
    lib_return();
  }

  private void f_get_s2m_addr()
  {
    // output: R3:s2m_addr
    int s2m_addr = 3;
    // s2m_addr = S2M_ADDR_H << S2M_ADDR_SHIFT;
    label("f_get_s2m_addr");
    lib_wait_dep_pre();
    as_mvi(s2m_addr, S2M_ADDR_H);
    lib_wait_dep_post();
    as_sli(s2m_addr, S2M_ADDR_SHIFT);
    lib_return();
  }

  private void f_get_vram_addr()
  {
    // output: R3:vram_addr
    int vram_addr = 3;
    // vram_addr = VRAM_ADDR_H << VRAM_ADDR_SHIFT;
    label("f_get_vram_addr");
    lib_wait_dep_pre();
    as_mvi(vram_addr, VRAM_ADDR_H);
    lib_wait_dep_post();
    as_sli(vram_addr, VRAM_ADDR_SHIFT);
    lib_return();
  }

  private void pe_thread_manager()
  {
    int my_core_id = 4;
    int parallel = 5;
    int task_id = 6;
    int vram_addr = 7;
    int m2s_addr = 8;
    int s2m_addr = 9;
    // temp
    int master_task_id = 10;
    int diff = 11;
    /*
    m2s_addr = lib_call("f_get_m2s_addr");
    vram_addr = lib_call("f_get_vram_addr");
    my_core_id = mem[m2s_addr];
    s2m_addr = lib_call("f_get_s2m_addr");
    s2m_addr += my_core_id;
    m2s_addr++;
    parallel = mem[m2s_addr];
    m2s_addr++;
    task_id = mem[m2s_addr];
    if (my_core_id >= parallel) goto "pe_thread_manager_L_end"
    do
    {
      task_id++;
      mem[s2m_addr] = task_id;
      do
      {
        master_task_id = mem[m2s_addr];
        diff = master_task_id - task_id;
      } while (diff != 0);
      lib_call("f_mandel");
    } (1);
    */
    as_nop();
    lib_init_stack();
    lib_call("f_get_m2s_addr");
    as_mv(m2s_addr, R3);
    lib_call("f_get_vram_addr");
    as_mv(vram_addr, R3);
    lib_call("f_get_s2m_addr");
    as_mv(s2m_addr, R3);
    as_ld(my_core_id, m2s_addr);
    lib_wait_dep_pre();
    as_addi(m2s_addr, 1);
    lib_wait_dep_post();
    as_mv(diff, my_core_id);
    as_add(s2m_addr, my_core_id);
    as_ld(parallel, m2s_addr);
    lib_wait_dep_pre();
    as_addi(m2s_addr, 1);
    lib_wait_dep_post();
    as_ld(task_id, m2s_addr);
    lib_wait_dep_pre();
    as_sub(diff, parallel);
    lib_wait_dep_post();
    as_cnm(SP_REG_CP, diff);
    lib_bc("pe_thread_manager_L_end");
    label("pe_thread_manager_L_0");
    lib_wait_dep_pre();
    as_addi(task_id, 1);
    lib_wait_dep_post();
    as_st(s2m_addr, task_id);
    label("pe_thread_manager_L_1");
    lib_wait_dep_pre();
    as_ld(master_task_id, m2s_addr);
    lib_wait_dep_post();
    lib_wait_dep_pre();
    as_mv(diff, master_task_id);
    lib_wait_dep_post();
    lib_wait_dep_pre();
    as_sub(diff, task_id);
    lib_wait_dep_post();
    as_cnz(SP_REG_CP, diff);
    lib_bc("pe_thread_manager_L_1");

    m_mandel();

    lib_ba("pe_thread_manager_L_0");
    label("pe_thread_manager_L_end");
    lib_call("f_halt");
    // link
    f_get_m2s_addr();
    f_get_s2m_addr();
    f_get_vram_addr();
    f_wait();
    f_halt();
  }

  @Override
  public void init()
  {
    set_rom_width(CODE_ROM_WIDTH, DATA_ROM_WIDTH);
    set_rom_depth(CODE_ROM_DEPTH, DATA_ROM_DEPTH);
    set_stack_address((1 << DATA_ROM_DEPTH) - 1);
    set_filename("default_pe");
  }

  @Override
  public void program()
  {
    pe_thread_manager();
  }

  @Override
  public void data()
  {
    label("d_rand");
    dat(0xfc720c27);
  }
}
