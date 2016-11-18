require "csv"

# Information about Heroku employees like github, trello, email and so on.
# From Kansa
class Employee
  include ActiveModel::Model
  attr_accessor :name, :id, :email, :github, :trello,
    :salesforce_email, :sudo, :role, :remote

  def self.find_by_github(github_login)
    employees_hash[github_login]
  end

  def self.by_heroku_email(heroku_email)
    all.detect do |employee|
      employee.email == heroku_email
    end
  end

  def self.all
    employees_hash.values
  end

  def self.employees_hash
    @employees_hash ||= generate_employees
  end

  def self.generate_employees
    filename = Rails.root.join("config/employees.csv")
    employees = {}
    CSV.foreach(filename, headers: true, quote_char: "\x00") do |eh|
      employee = new(
        name:             eh["Name"],
        id:               eh["Heroku ID"],
        email:            eh["Email"],
        github:           eh["Github"],
        trello:           eh["Trello"],
        salesforce_email: eh["Salesforce Email"],
        sudo:             eh["Sudo role"],
        role:             eh["Manager/IC/Contractor"],
        remote:           eh["Remote/Local"]
      )
      employees[employee.github] = employee
    end
    employees
  end

  def remote?
    remote == "Remote"
  end
end
