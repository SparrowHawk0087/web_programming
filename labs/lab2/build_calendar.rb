# Проверка аргументов
if ARGV.size != 4
  puts "Пожалуйста, используйте такую последовательность вызовов в консоли:\nruby build_calendar.rb teams.txt ДД.ММ.ГГГГ ДД.ММ.ГГГГ calendar.txt"
  exit 1
end

script_fname, teams_fname, start_date, end_date, output_fname = ARGV

# Старт чтения команд из файла
unless File.exist?(teams_fname)
  puts "Файл не найден"
  exit 1
end

teams = File.read(teams_fname)
puts teams

File.close

