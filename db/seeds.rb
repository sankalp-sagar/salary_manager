# Salary Manager - Seeding Script
# Generates 10,000 employees with realistic data
# Usage: rails db:seed

puts "🌱 Starting database seeding..."
User.create(email: 'hr@test.com', password: 'password', password_confirmation: 'password', role: 1, first_name: 'HR', last_name: 'Manager')
User.create(email: 'admin@test.com', password: 'password', password_confirmation: 'password', role: 2, first_name: 'Admin', last_name: 'User')

# Clear existing employees (idempotent)
Employee.delete_all
puts "Cleared existing employees"

FIRST_NAMES = [
  "James", "Mary", "Robert", "Patricia", "Michael", "Jennifer", "William", "Linda",
  "David", "Barbara", "Richard", "Elizabeth", "Joseph", "Susan", "Thomas", "Jessica",
  "Charles", "Sarah", "Christopher", "Karen", "Daniel", "Nancy", "Matthew", "Lisa",
  "Anthony", "Betty", "Donald", "Margaret", "Mark", "Sandra", "Steven", "Ashley",
  "Paul", "Kimberly", "Andrew", "Donna", "Joshua", "Carol", "Kenneth", "Michelle",
  "Kevin", "Amanda", "Brian", "Melissa", "George", "Deborah", "Edward", "Stephanie",
  "Ronald", "Rebecca", "Timothy", "Sharon", "Jason", "Laura", "Jeffrey", "Cynthia",
  "Ryan", "Kathleen", "Jacob", "Amy", "Gary", "Angela", "Nicholas", "Shirley",
  "Eric", "Anna", "Jonathan", "Brenda", "Stephen", "Pamela", "Larry", "Emma",
  "Justin", "Nicole", "Scott", "Helen", "Brandon", "Samantha", "Benjamin", "Katherine",
  "Samuel", "Christine", "Frank", "Debra", "Gregory", "Rachel", "Alexander", "Catherine"
].freeze

LAST_NAMES = [
  "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
  "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas",
  "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson", "White",
  "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker", "Young",
  "Allen", "King", "Wright", "Scott", "Torres", "Peterson", "Phillips", "Campbell",
  "Parker", "Edwards", "Collins", "Reyes", "Stewart", "Morris", "Morales", "Murphy",
  "Cook", "Rogers", "Gutierrez", "Ortiz", "Morgan", "Cooper", "Peterson", "Hunter",
  "Hicks", "Crawford", "Henry", "Boyd", "Mason", "Moreno", "Kennedy", "Warren",
  "Dixon", "Ramos", "Reeves", "Burns", "Gordon", "Shaw", "Holmes", "Rice",
  "Robertson", "Hunt", "Black", "Daniels", "Palmer", "Mills", "Nichols", "Grant",
  "Knight", "Ferguson", "Stone", "Hawkins", "Duffy", "Perkins", "Hudson", "Spencer"
].freeze

COUNTRIES = [
  "USA", "UK", "Canada", "India", "Germany", "France", "Australia", "Japan",
  "Singapore", "Ireland", "Netherlands", "Sweden", "Switzerland", "Spain", "Brazil",
  "Mexico", "South Korea", "New Zealand", "China", "Israel"
].freeze

JOB_TITLES = [
  "Software Engineer", "Senior Software Engineer", "Staff Engineer", "Engineering Manager",
  "Product Manager", "Senior Product Manager", "Data Scientist", "Data Analyst",
  "DevOps Engineer", "Cloud Architect", "QA Engineer", "Systems Administrator",
  "Database Administrator", "UX Designer", "UI Designer", "Product Designer",
  "Technical Writer", "Solutions Architect", "Business Analyst", "IT Manager",
  "Finance Manager", "HR Manager", "Recruiter", "Sales Manager", "Account Executive",
  "Customer Success Manager", "Marketing Manager", "Operations Manager", "Director of Engineering",
  "VP of Engineering", "CTO", "CEO", "CFO", "COO"
].freeze

SALARY_RANGES = {
  "Software Engineer" => (80_000..150_000),
  "Senior Software Engineer" => (120_000..200_000),
  "Staff Engineer" => (150_000..250_000),
  "Engineering Manager" => (110_000..200_000),
  "Product Manager" => (100_000..180_000),
  "Senior Product Manager" => (130_000..220_000),
  "Data Scientist" => (90_000..160_000),
  "Data Analyst" => (60_000..120_000),
  "DevOps Engineer" => (95_000..170_000),
  "Cloud Architect" => (120_000..210_000),
  "QA Engineer" => (70_000..130_000),
  "Systems Administrator" => (65_000..125_000),
  "Database Administrator" => (80_000..150_000),
  "UX Designer" => (75_000..140_000),
  "UI Designer" => (70_000..130_000),
  "Product Designer" => (85_000..155_000),
  "Technical Writer" => (60_000..110_000),
  "Solutions Architect" => (110_000..190_000),
  "Business Analyst" => (65_000..125_000),
  "IT Manager" => (85_000..155_000),
  "Finance Manager" => (90_000..165_000),
  "HR Manager" => (75_000..140_000),
  "Recruiter" => (55_000..100_000),
  "Sales Manager" => (80_000..160_000),
  "Account Executive" => (70_000..150_000),
  "Customer Success Manager" => (65_000..130_000),
  "Marketing Manager" => (80_000..150_000),
  "Operations Manager" => (75_000..145_000),
  "Director of Engineering" => (150_000..280_000),
  "VP of Engineering" => (180_000..350_000),
  "CTO" => (200_000..400_000),
  "CEO" => (250_000..500_000),
  "CFO" => (220_000..420_000),
  "COO" => (210_000..400_000)
}.freeze

COUNTRY_MULTIPLIERS = {
  "USA" => 1.0,
  "UK" => 0.85,
  "Canada" => 0.90,
  "Australia" => 0.92,
  "Switzerland" => 1.15,
  "Germany" => 0.88,
  "France" => 0.80,
  "Netherlands" => 0.90,
  "Sweden" => 0.95,
  "Ireland" => 0.88,
  "Japan" => 0.75,
  "Singapore" => 0.95,
  "Israel" => 0.72,
  "India" => 0.25,
  "South Korea" => 0.60,
  "New Zealand" => 0.85,
  "Brazil" => 0.40,
  "Mexico" => 0.35,
  "Spain" => 0.70,
  "China" => 0.45
}.freeze

def generate_employee
  first_name = FIRST_NAMES.sample
  last_name = LAST_NAMES.sample
  job_title = JOB_TITLES.sample
  country = COUNTRIES.sample

  base_range = SALARY_RANGES[job_title] || (60_000..100_000)
  multiplier = COUNTRY_MULTIPLIERS[country] || 1.0
  base_salary = rand(base_range)
  salary = (base_salary * multiplier).round(-2).to_i

  start_date = 5.years.ago.to_date
  days_back = rand(0..(Date.today - start_date).to_i)
  joining_date = Date.today - days_back

  left_at = if rand < 0.2
    days_left = rand(0..((Date.today - joining_date).to_i - 180))
    joining_date + days_left.days + 6.months rescue nil
  else
    nil
  end

  {
    first_name: first_name,
    last_name: last_name,
    job_title: job_title,
    country: country,
    salary: salary,
    joining_date: joining_date,
    left_at: left_at,
    created_at: Time.current,
    updated_at: Time.current
  }
end

# Seed 10,000 employees in batches
BATCH_SIZE = 500
TOTAL_EMPLOYEES = 10_000

puts "Generating #{TOTAL_EMPLOYEES} employees in batches of #{BATCH_SIZE}..."

(TOTAL_EMPLOYEES / BATCH_SIZE).times do |batch_num|
  employees = BATCH_SIZE.times.map { generate_employee }
  Employee.insert_all(employees)

  progress = (batch_num + 1) * BATCH_SIZE
  percentage = ((progress.to_f / TOTAL_EMPLOYEES) * 100).round(1)
  puts "Created #{progress}/#{TOTAL_EMPLOYEES} employees (#{percentage}%)"
end


total_count = Employee.count
active_count = Employee.where(left_at: nil).count
former_count = Employee.where.not(left_at: nil).count
avg_salary = Employee.average(:salary).round(2)
max_salary = Employee.maximum(:salary)
min_salary = Employee.minimum(:salary)
countries_count = Employee.distinct.count(:country)
job_titles_count = Employee.distinct.count(:job_title)

puts "\n🎉 Seeding Complete!"
puts "━" * 50
puts "📈 Database Statistics:"
puts "  • Total Employees: #{total_count}"
puts "  • Active Employees: #{active_count} (#{((active_count.to_f/total_count)*100).round(1)}%)"
puts "  • Former Employees: #{former_count} (#{((former_count.to_f/total_count)*100).round(1)}%)"
puts "  • Countries: #{countries_count}"
puts "  • Job Titles: #{job_titles_count}"
puts "\n💰 Salary Statistics:"
puts "  • Average Salary: $#{avg_salary.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
puts "  • Min Salary: $#{min_salary.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
puts "  • Max Salary: $#{max_salary.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
puts "━" * 50
puts "✨ Database is ready for use!"
