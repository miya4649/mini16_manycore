// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2019 miya All rights reserved.

import java.io.*;
import java.util.*;

public class GetOpt
{
  private final HashMap<String, String> p_opts = new HashMap<String, String>();

  public void setArgs(String[] args)
  {
    p_opts.clear();
    for (int i = 0; i < args.length; i++)
    {
      String[] arg = args[i].split("=");
      if (arg.length == 2)
      {
        String key = arg[0].replace("-", "");
        String value = arg[1];
        p_opts.put(key, value);
      }
    }
  }

  public void print_error(String err)
  {
    System.out.printf("Error: GetOpt: %s\n", err);
    System.exit(1);
  }

  public String getValue(String key)
  {
    if (p_opts.get(key) == null)
    {
      print_error("getValue: " + key);
    }
    return p_opts.get(key);
  }

  public int getIntValue(String key)
  {
    if (p_opts.get(key) == null)
    {
      print_error("getIntValue: " + key);
    }
    return Integer.parseInt(p_opts.get(key));
  }

  public void setDefault(String key, String value)
  {
    if (p_opts.get(key) == null)
    {
      set(key, value);
    }
  }

  public void setDefault(String key, int value)
  {
    if (p_opts.get(key) == null)
    {
      set(key, value);
    }
  }

  public void set(String key, String value)
  {
    p_opts.put(key, value);
  }

  public void set(String key, int value)
  {
    p_opts.put(key, Integer.toString(value));
  }
}
