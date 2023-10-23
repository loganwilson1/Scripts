Class ITestBoolService {
    # empty constructor
    ITestBoolService()
    {
        Write-Host("Hitting empty constructor for ITestBoolService")
    }
    
    # Methods
    [bool]GetTrue() 
    {
        return $true
    }
    [bool]GetFalse() 
    {
        return $false
    }
    [bool]GetSameBool([bool]$bool) 
    {
        return $bool
    }
    [bool]GetOppositeBool([bool]$bool) 
    {
        return !$bool
    }
}

Class IMath {
    #Fields (Properties)
    [ITestBoolService] $TestBoolService

    # Empty contructor
    IMath()
    {
        Write-Host("Hitting empty constructor for IMath")
        $this.TestBoolService = [ITestBoolService]::new()
    }

    # Methods
    [int]Sum($x,$y)  
    {
        return $x + $y
    }
    [int]Subtract($x,$y)
    {
        return $x - $y
    }
    [int]Difference($x,$y)
    {
        $subtractResult = $this.Subtract($x,$y)
        return [Math]::Abs($subtractResult)
    }
    [bool]AreEqual($x,$y)
    {
        $numbersEqual = ($x -eq $y)
        # $bool = $this.TestBoolService.GetTrue()
        # $bool = $this.TestBoolService.GetFalse()
        $bool = $this.TestBoolService.GetSameBool($true)
        $bool = $this.TestBoolService.GetOppositeBool($true)
    
        # Not a great example of how to use an interface within another class, but it demostrates the point
        return ($numbersEqual -and $bool)
    }
}

# Using IMath service's empty constructor, the ITestBoolService will be created and used within IMath as needed
[IMath]$mathService=[IMath]::new()
$mathService.Sum(4,6) # returns 10
$mathService.Subtract(4,6) # returns -2
$mathService.Difference(4,6) # returns 2
$mathService.AreEqual(2,2)