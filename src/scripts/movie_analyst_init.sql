-- Create the database
CREATE DATABASE IF NOT EXISTS movie_analyst;
USE movie_analyst;

-- Create movies table
CREATE TABLE IF NOT EXISTS movies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  rating DECIMAL(3,1) NOT NULL,
  release_date DATE NOT NULL,
  image_url VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create reviewers table
CREATE TABLE IF NOT EXISTS reviewers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  avatar VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create publications table
CREATE TABLE IF NOT EXISTS publications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  avatar VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create reviews table (implied by relationships)
CREATE TABLE IF NOT EXISTS reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  movie_id INT NOT NULL,
  reviewer_id INT NOT NULL,
  publication_id INT NOT NULL,
  rating DECIMAL(3,1) NOT NULL,
  review TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (movie_id) REFERENCES movies(id),
  FOREIGN KEY (reviewer_id) REFERENCES reviewers(id),
  FOREIGN KEY (publication_id) REFERENCES publications(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert sample movies data (from seeds.js)
INSERT INTO movies (title, rating, release_date, image_url) VALUES
('The Shawshank Redemption', 9.3, '1994-09-23', 'https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg'),
('The Godfather', 9.2, '1972-03-24', 'https://image.tmdb.org/t/p/w500/rPdtLWNsZmAtoZl9PK7S2wE3qiS.jpg'),
('The Dark Knight', 9.0, '2008-07-16', 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg');

-- Insert sample reviewers data
INSERT INTO reviewers (name, avatar) VALUES
('Robert Smith', 'https://randomuser.me/api/portraits/men/32.jpg'),
('Jane Doe', 'https://randomuser.me/api/portraits/women/44.jpg'),
('Alice Johnson', 'https://randomuser.me/api/portraits/women/68.jpg');

-- Insert sample publications data
INSERT INTO publications (name, avatar) VALUES
('The Daily Reviewer', 'https://randomuser.me/api/portraits/men/75.jpg'),
('International Movie Critic', 'https://randomuser.me/api/portraits/men/19.jpg'),
('MoviesNow', 'https://randomuser.me/api/portraits/women/33.jpg'),
('MyNextReview', 'https://randomuser.me/api/portraits/men/22.jpg'),
('Movies n\' Games', 'https://randomuser.me/api/portraits/women/53.jpg'),
('TheOne', 'https://randomuser.me/api/portraits/men/46.jpg'),
('ComicBookHero.com', 'https://randomuser.me/api/portraits/women/11.jpg');

-- Insert sample reviews data
INSERT INTO reviews (movie_id, reviewer_id, publication_id, rating, review) VALUES
(1, 1, 1, 9.5, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'),
(1, 2, 2, 9.0, 'Nulla facilisi. Vivamus euismod, ipsum eu volutpat.'),
(2, 1, 3, 9.3, 'Pellentesque habitant morbi tristique senectus et netus.'),
(2, 3, 4, 9.1, 'Duis aute irure dolor in reprehenderit in voluptate.'),
(3, 2, 5, 8.8, 'Excepteur sint occaecat cupidatat non proident.'),
(3, 3, 6, 8.9, 'Ut enim ad minim veniam, quis nostrud exercitation.');

-- Create application user with restricted privileges
CREATE USER 'movie_analyst'@'%' IDENTIFIED BY 'AnalystPassword123!';
GRANT SELECT, INSERT, UPDATE, DELETE ON movie_analyst.* TO 'movie_analyst'@'%';
FLUSH PRIVILEGES;