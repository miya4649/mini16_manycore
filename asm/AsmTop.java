// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2016 miya All rights reserved.

public class AsmTop
{
  private static final MasterProgram mp = new MasterProgram();
  private static final PEProgram pp = new PEProgram();
  private static final BootProgram bp = new BootProgram();

  public static void main(String[] args)
  {
    mp.do_asm(args);
    pp.do_asm(args);
    bp.do_asm(args);
  }
}
