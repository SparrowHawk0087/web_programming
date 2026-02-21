require 'date'

# захват, обработка и проверка дат
def parse_event_dates(start_date_str, end_date_str)
  #  Создание объекта даты из строки
  start_date = Date.strptime(start_date_str, '%d.%m.%Y')
  end_date = Date.strptime(end_date_str, '%d.%m.%Y')

  unless start_date < end_date
    # Принудительно форматируем дату через strftime для вывода, потому что иначе нули перед годом
    puts "Ошибка: Дата начала (#{start_date.strftime('%y-%m-%d')}) позже даты конца (#{end_date.strftime('%y-%m-%d')})"
    exit 1
  end

  [start_date, end_date]
end

# Проверка аргументов
if ARGV.size != 4
  puts "Пожалуйста, используйте такую последовательность вызовов в консоли:\nruby build_calendar.rb teams.txt ДД.ММ.ГГГГ ДД.ММ.ГГГГ calendar.txt"
  exit 1
end

teams_fname, start_date, end_date, output_fname = ARGV

# Старт чтения команд из файла
unless File.exist?(teams_fname)
  puts "Ошибка: файл #{teams_fname} не найден."
  exit 1
end

# захват, обработка и проверка дат
start_obj, end_obj = parse_event_dates(start_date, end_date)
puts "Период валиден: с #{start_obj.strftime('%d.%m.%y')} по #{end_obj.strftime('%d.%m.%y')}"
puts "Файл с командами: #{teams_fname}"
puts "Период: с #{start_date} по #{end_date}"
puts "Результат будет в: #{output_fname}"

data = File.readlines(teams_fname, chomp: true)

expr = /\A(?:\d+\.\s*)(?<team>.+?)\s*—\s*(?<city>.+)\z/

hash_data = data.each_with_object(Hash.new { |h, k| h[k] = [] }) do |line, h|
  if m = line.match(expr)
    h[m[:city]] << m[:team]
  end
end

# Убираем дубликаты в каждом городе
hash_data.each_value(&:uniq!)

# TODO: Сеты данных

# Преобразуем хеш городов в список команд

teams = []

hash_data.each do |city, teams_names|
  teams_names.each { |name| teams << { name: name, city: city } }
end

# Проверка на минимальное количество команд
if teams.size < 2
  puts 'Ошибка: должно быть минимум 2 команды.'
  exit 1
end

# Убираем дубликаты команд
teams.uniq!

puts "Всего команд: #{teams.size}"

# Генерируем все возможные игры (А-Б Б-А допустимы)
all_games = teams.permutation(2).to_a

# Простое перемешивание
all_games.shuffle!

days = (start_obj..end_obj).select { |d| [0, 5, 6].include?(d.wday) }

# Генерируем все возможные пары [день, время]
slots = days.product(['12:00', '15:00', '18:00'])

# Проверка наличия игровых дней
if slots.empty?
  puts 'Ошибка: в указанном диапазоне нет игровых дней (пт, сб, вс).'
  exit 1
end

# Проверка достаточности мест
max_games = slots.size * 2
if all_games.size > max_games
  puts "Ошибка: слишком много игр (#{all_games.size}) для доступных слотов (максимум #{max_games})."
  exit 1
end

calendar = []

# Хеш для быстрого отслеживания занятости: day => { teams: Set, cities: Set }

usage = Hash.new { |h, k| h[k] = { t: Set.new, c: Set.new } }

# Распределение 
total_slots = slots.size
total_games = all_games.size

all_games.each_with_index do |(home, away), idx|
  # Целевой индекс
  target = total_games == 1 ? total_slots / 2 : (idx * (total_slots - 1) / (total_games - 1)).round

  # Все индексы слотов, отсортированные по близости к target
  indices = (0...total_slots).sort_by { |i| (i - target).abs }

  found = indices.find do |pos|
    day, time = slots[pos]
    next if calendar.count { |g| g[:d] == day && g[:t] == time } >= 2

    day_use = usage[day]
    next if day_use[:t].include?(home[:name]) || day_use[:t].include?(away[:name])
    next if day_use[:c].include?(home[:city])

    day_use[:t].merge([home[:name], away[:name]])
    day_use[:c].add(home[:city])
    calendar << { d: day, t: time, h: home, a: away }
    true
  end

  unless found
    puts "Ошибка: не удалось найти слот для игры #{home[:name]} vs #{away[:name]}"
    exit 1
  end
end

# Сортируем календарь по дате и времени
calendar.sort_by! { |g| [g[:d], g[:t]] }

# TODO: Запись в файл

DAY_NAMES = %w[воскресенье понедельник вторник среда четверг пятница суббота].freeze
MONTH_NAMES = %w[января февраля марта апреля мая июня июля августа сентября октября ноября декабря].freeze

File.open(output_fname, 'w:UTF-8') do |f|
  f.puts "Календарь игр с #{start_date} по #{end_date}\n\n"

  current_date = nil
  calendar.each do |game|
    date = game[:d]
    time = game[:t]
    home = game[:h]
    away = game[:a]

    if date != current_date
      # Выводим заголовок с днём недели и датой
      day_name = DAY_NAMES[date.wday].capitalize
      month_name = MONTH_NAMES[date.month - 1]
      f.puts "#{day_name}, #{date.day} #{month_name} #{date.year}:"
      current_date = date
    end

    f.puts "  #{time}:"
    f.puts "    - #{home[:name]} (#{home[:city]}) vs #{away[:name]} (#{away[:city]})"
  end
end
