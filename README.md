# PathOGion
An iOS application that displays potential intersection points between the user's prior locations and the confirmed paths of people infected with contagious diseases

// To Do

Create LocationPath class

  Function that determines intersection
  
    Determine return type
  
    Algorithm: (incomplete)
  
      Make sure that start and end timestamps of paths intersect
  
        If mutually exclusive
  
          return empty intersection
  
        If intersect
        [first check based on spatial distance
        then filter based on if it was during the same time]
          Clip paths
  
      If points intersect with any other points, check timestamp accuracy specifically


Extend LocationPoint 
  
  Convenience functions
  
    Distance
  
    Interpolate (based on timestamps of two points)
