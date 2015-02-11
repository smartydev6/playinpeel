class Activity
  include Mongoid::Document

  field :Name
  field :Description
  field :AgeFrom
  field :AgeTo
  field :Code
  field :DropIn
  field :Fees
  field :Times

  validates :Code, uniqueness: true
  # 33729


  def self.search(params)

    days = params['days'].split(',')
    days_array = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    days_condition = {}
    days.each_with_index do |day, index|
      b = to_b(day)
      days_condition["Times.#{days_array[index]}"] = true if b
    end

    r = params['timesOfDay'].split(',')
    timesOfDay = [to_b(r[0]) ? 'AM':nil, to_b(r[1]) ? 'PM':nil]

    r = params['activityTypes'].split(',')
    activityTypes = [to_b(r[0]), to_b(r[1])]

    return Activity.where(
      "AgeFrom" => {"$gte"=>params['ageFrom'].to_i},
      "AgeTo" => {"$gte"=>params['ageTo'].to_i},
      "AgeTo" => {"$gte"=>params['ageTo'].to_i},
      "Times.StartDate"=>{"$gte"=>Date.strptime(params['dateFrom'],'%m-%d-%Y')},
      "Times.EndDate"=>{"$lte"=>Date.strptime(params['dateTo'],'%m-%d-%Y')},
      "Times.timesOfDay" => { "$in" => timesOfDay },
      "DropIn" => { "$in" => activityTypes }
      ).any_of(
        days_condition
      )
    .skip((params['skip'].to_i-1)*params['take'].to_i).take(params['take'].to_i)
  end

  private
    def self.to_b(value)
      value == 'true'
    end
end
