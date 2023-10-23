# Create a class called Person, and a class called Student which inherits from Person
class Person 
{
    # Properties
    [string] $FirstName
    [string] $MiddleInitial
    [string] $LastName

    # Constructors
    Person(
        [string] $FirstName, 
        [string] $MiddleInitial, 
        [string] $LastName) 
    {
        Write-Host("Person class 'Person' constructor")
        $this.FirstName = $FirstName
        $this.MiddleInitial = $MiddleInitial
        $this.LastName = $LastName
    }

    # Methods
    [string] GetFullName() {
        $fullName = @()
        
        if (![string]::IsNullOrWhiteSpace($this.FirstName)) {
            $fullName += $this.FirstName
        }
        
        if (![string]::IsNullOrWhiteSpace($this.MiddleInitial)) {
            $fullName += $this.MiddleInitial
        }
        
        if (![string]::IsNullOrWhiteSpace($this.LastName)) {
            $fullName += $this.LastName
        }

        return $fullName -join ' '
    }
}

class Student : Person
{ 
    # Properties
    [int]$GraduatingYear 
    [decimal]$GPA

    # Constructor for Student (including base class constructor)
    Student(
        [string] $FirstName, 
        [string] $MiddleInitial, 
        [string] $LastName,  
        [int]$GraduatingYear, 
        [decimal]$GPA) 
        <# 
            by calling the base this way, we don't need to maintain or override these properties witin the sub class  
        #>
        : base ($FirstName, $MiddleInitial, $LastName) 
    {
        Write-Host("Student class 'Student' constructor")
        $this.GraduatingYear = $GraduatingYear
        $this.GPA = $GPA 
    }
}

# Example usage:
$person1 = [Person]::new('John', 'D', 'Doe')
$person2 = [Person]::new('Jane', '', 'Smith')
$student3 = [Student]::new('Jack', 'S', 'Hancock', 2024, 3.45)

# Generic object array
$peopleArray = @()
$peopleArray += $person1
$peopleArray += $person2
$peopleArray += $student3

# Better yet, use an array of that type
[Person[]]$people = @()
$people += $person1
$people += $person2
$people += $student3

# Get data from the array and use a method on that class
Write-Host "Person 1 Full Name: $($people[0].GetFullName())" # Output: "John D Doe"
Write-Host "Person 2 Full Name: $($people[1].GetFullName())" # Output: "Jane Smith"
Write-Host "Person 3 Full Name: $($people[2].GetFullName())" # Output: "Jack S Hancock"