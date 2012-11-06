class Movie < ActiveRecord::Base
  class Movie::InvalidKeyError < StandardError ; end
  RATINGS = %w[G PG PG-13 R NC-17]  #  %w[] shortcut for array of strings
  validates :title, :presence => true
  validates :release_date, :presence => true
  validate :released_1930_or_later # uses custom validator below
  validates :rating, :inclusion => {:in => RATINGS}, :unless => :grandfathered?
  def released_1930_or_later
    errors.add(:release_date, 'must be 1930 or later') if
      self.release_date < Date.parse('1 Jan 1930')
  end
  def grandfathered? ; self.release_date < Date.parse('1 Nov 1968') ; end
  attr_accessible :title, :release_date, :rating
   
  def self.find_in_tmdb(string)
    Tmdb.api_key = self.api_key
    begin
      TmdbMovie.find(:title => string, :limit => 1)
      rescue ArgumentError => tmdb_error
        raise Movie::InvalidKeyError, tmdb_error.message
      rescue RuntimeError => tmdb_error
        if tmdb_error.message =~ /status code '404'/
          raise Movie::InvalidKeyError, tmdb_error.message
        else
          raise RuntimeError, tmdb_error.message
        end

    end
  end

  def self.api_key
    'fac48ad692c906c5fd854ce583fd998c'
  end
end
