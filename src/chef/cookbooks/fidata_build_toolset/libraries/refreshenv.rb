require 'win32/registry'

def get_reg_env(hkey, subkey, &block)
  Win32::Registry.open(hkey, subkey) do |reg|
    reg.each_value do |name|
      value = reg.read_s_expand(name)
      if block && ENV.key?(name)
        ENV[name] = block.call(name, ENV[name], value)
      else
        ENV[name] = value
      end
    end
  end
end

def refresh_env
  get_reg_env(Win32::Registry::HKEY_LOCAL_MACHINE, 'System\CurrentControlSet\Control\Session Manager\Environment')
  get_reg_env(Win32::Registry::HKEY_CURRENT_USER, 'Environment') do |name, old_value, new_value|
    if name.upcase == 'PATH'
      old_value || File::PATH_SEPARATOR || new_value
    else
      new_value
    end
  end
end
