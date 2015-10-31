class Player < ActiveRecord::Base
  has_many :scores
  has_many :personal_match_infos
  has_many :matches, through: :scores
  has_many :match_talent_glyph_selections

  filterrific(
    default_filter_params: { sorted_by: 'name_asc' },
    available_filters: [
      :sorted_by,
      :with_class_name,
      :with_spec_name,
      :with_teammate
    ]
  )

  scope :sorted_by, lambda { |sort_key|
    direction = sort_key =~ /desc$/ ? 'desc' : 'asc'
    case sort_key.to_s
    when /^name_/
      order "players.name #{direction}"
    else
      raise ArgumentError, "Invalid sort option: #{ sort_option.inspect }"
    end
  }

  scope :with_class_name, lambda { |class_names|
    where class_name: [*class_names]
  }

  scope :with_spec_name, lambda { |spec_names|
    where spec_name: [*spec_names]
  }

  scope :with_match, lambda { |matches|
    where match: [*matches]
  }

  scope :with_teammate, lambda { |players|
    where id: [*players].inject([]) { |a,p| 
        Score.where(player: p).inject(a) {|a,s| 
          a += Score.where(match: s.match, player_faction: s.player_faction).map{|s|s.player} 
        }
    }.uniq.map(&:id)
  }

  def self.options_for_select
    order('LOWER(name)').map { |e| [e.name, e.id] }
  end

end
