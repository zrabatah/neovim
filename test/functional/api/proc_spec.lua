local helpers = require('test.functional.helpers')(after_each)

local clear, eq = helpers.clear, helpers.eq
local funcs = helpers.funcs
local nvim_argv = helpers.nvim_argv
local request = helpers.request
local retry = helpers.retry

describe('api', function()
  before_each(clear)

  describe('nvim_get_proc_children', function()
    it('returns child process ids', function()
      local this_pid = funcs.getpid()

      local job1 = funcs.jobstart(nvim_argv)
      retry(nil, nil, function()
        eq(1, #request('nvim_get_proc_children', this_pid))
      end)

      local job2 = funcs.jobstart(nvim_argv)
      retry(nil, nil, function()
        eq(2, #request('nvim_get_proc_children', this_pid))
      end)

      funcs.jobstop(job1)
      retry(nil, nil, function()
        eq(1, #request('nvim_get_proc_children', this_pid))
      end)

      funcs.jobstop(job2)
      retry(nil, nil, function()
        eq(0, #request('nvim_get_proc_children', this_pid))
      end)
    end)

    it('validates input', function()
      local status, rv = pcall(request, "nvim_get_proc_children", -1)
      eq(false, status)
      eq("Invalid pid: -1", string.match(rv, "Invalid.*"))

      status, rv = pcall(request, "nvim_get_proc_children", 0)
      eq(false, status)
      eq("Invalid pid: 0", string.match(rv, "Invalid.*"))

      -- Assume PID 99999999 does not exist.
      status, rv = pcall(request, "nvim_get_proc_children", 99999999)
      eq(true, status)
      eq({}, rv)
    end)
  end)

end)
