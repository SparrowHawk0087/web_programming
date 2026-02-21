puts 1.class.superclass.superclass.superclass.methods
puts 2.7.class.superclass

puts true.class
puts false.class

puts nil.class # spec-object 
# snake_case
# local variables and func-names

# camelCase
# Ruby doesn't use

# PascalCase
# modules and classes

# kebab-case
# In Ruby it's incorrect

# Screaming snake shake
# constants

site = 'sfedu.ru' # local

@user = 'alice' # instance
# @@count = 0 # class static
$env = 'dev' # global
APP_NAME = 'Ruby1.2' # constant

def f(a, b, condition)
  if condition
    a + b
  else
    a - b
  end
end

def f(a, b, file_is_correct, network_is_correct)
  if !file_is_correct
    report_file_error
  elsif !network_is_correct
    report_network_error
  else
    # 400 строк кода -- happy path
    a + b
  end
end

def fv2(a, b, file_is_correct, network_is_correct)
  # Guard Clause
  return report_file_error unless file_is_correct
  return report_network_error unless network_is_correct

  # 400 code string -- happy path
  a + b
end

def f3(a, b = 2, c = 3)
  a + b + c
end

def f4(a, b: 2, c: 3)
  a + b + c
end

def greet(name, lang: 'ru')
  puts 'Hello dummy {name}!'
end

puts f3(1, 2, 3)
puts f3(1, 4)
puts f3(2, 3, 4)
