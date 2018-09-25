Describe "Get-IndexedItem" {
    $testCases1 = @( #Search recursively for a KIND of a file with a KEYWORD and FREETEXT in a given folder
       @{  kind = 'Picture'; keyword='Portfolio'; Path="~";  ContainsText  = 'Stingray' }
    )
    $TestCases2 = @( #Search recursively and non-recursively for a KIND of a file with a KEYWORD and FREETEXT in a given folder
        @{ kind = 'Picture'; keyword="PortFolio" ;  path =([system.environment]::GetFolderPath( [system.environment+specialFolder]::MyPictures ))}
    )
    $testCases3 = @( #Search using a filter, expect a kind of file to be returned with a given property present
       @{ kind = 'Music'; Filter = "System.Kind = 'Music' AND AlbumArtist like '%' "; path= "C:\Users"; shortProperty ='AlbumArtist';  longProperty ='SYSTEM.MUSIC.ALBUMARTIST' }
    )

    it "Returned at least one '<kind>' file recursing <path> containing '<ContainsText>' with keyword '<keyword>'" -TestCases $testCases1 {
        Param ($containsText,$kind,$keyword,$path )
        $i = Get-IndexedItem -Filter "Contains(*,'$containsText')", "kind = '$kind'", "keywords='$Keyword'" -path $path -recurse
        $i                                                              | Should not beNullOrEmpty
        $i[0].GetType().name                                            | Should     be FileInfo
        $i[0].Keyword -contains $keyword                                | Should     be $true
        $script:FirstName  = $i[0].Name
        $script:FoundCount = $i.count

    }
    it "Returned the same result with shortened syntax"                                  -TestCases $testCases1 {
        Param ($containsText,$kind,$keyword,$path )
        $i = $null
        $i = Get-IndexedItem $containsText, "kind=$kind", "keyword=$Keyword"  -recurse $path
        $i                                                              | Should not beNullOrEmpty
        $i[0].GetType().name                                            | Should     be FileInfo
        $i[0].Keyword -contains $keyword                                | Should     be $true
        $i[0].name                                                      | Should     be $Script:firstName
        $i.count | should be $script:FoundCount
        $f = $i | Select-Object -first 1 | copy-item -Destination $env:TEMP -PassThru
        $f                                                              | Should not beNullOrEmpty
        $f.name                                                         | Should     be $i[0].name
        {Remove-Item -Path $f }                                         | Should not throw
    }
    it "Found keywords   including    '<keyword>' in <path>"                             -TestCases $testCases2 {
        Param ($Path , $keyword,$Kind)
        $k = Get-IndexedItem -Value Keyword -Path $path -Recurse
        $k                                                              | Should not beNullOrEmpty
        $k.Keyword -contains $keyword                                   | Should     be $true
    }
    it "Found items Where keyword -eq '<keyword>' in <path>"                             -TestCases $testCases2 {
        Param ($Path , $keyword,$Kind)
        $i = $null
        $i = Get-IndexedItem -Path $path -Recurse -Where Keyword -eq $keyword
        $I | Should not beNullOrEmpty
        $i[0].keywords -contains $keyword                               | Should be $true
    }
    it "Returned more '<kind>' files recursing <path> than not recursing it"             -TestCases $testCases2 {
        Param ($kind,$keyword,$path )
        $i = Get-IndexedItem -Filter "kind = '$kind'" -path $path -Bare -NoFiles
        $i                                                              | Should not beNullOrEmpty
        $J = Get-IndexedItem -Filter "kind = '$kind'" -path $path -Bare -NoFiles -Recurse
        $J.count                                                        | Should     beGreaterThan $i.Count
    }
    it "Got Results for ""<Filter>"" for whole index with -NoFiles option "              -TestCases $testCases3 {
        Param ($filter, $path , $Kind,  $shortProperty, $longProperty)
        $i = $null
        $i = Get-IndexedItem -Filter $filter -NoFiles -Recurse
        $i                                                              | Should not beNullOrEmpty
        $i[0].GetType().name                                            | Should not be FileInfo   #With -NoFiles should not become file info
        $i[0].GetType().name                                            | Should not be DataRow    #Without bare  should be a ps custom object
        $i[0].KIND                                                      | Should     be $Kind
        $i[0].$shortProperty                                            | Should not beNullOrEmpty #Without bare system.whatever.Thing becomes things
        $i[0].$longProperty                                             | Should     beNullOrEmpty
    }
    it "Got Results for ""<Filter>"" for Whole index with -NoFiles and -Bare Options"    -TestCases $testCases3 {
        Param  ($filter, $path , $Kind,  $shortProperty, $longProperty)
        $i = $null
        $i = Get-IndexedItem -Filter $filter -NoFiles -bare -Recurse
        $i                                                              | Should not beNullOrEmpty
        $i[0].GetType().name                                            | Should not be FileInfo
        $i[0].GetType().name                                            | Should     be DataRow
        $i[0]."SYSTEM.KIND"                                             | Should     be $Kind
        $i[0].$shortProperty                                            | Should     beNullOrEmpty  #Without bare system.whatever.Thing remains as is
        $i[0].$longProperty                                             | Should not beNullOrEmpty
    }
    it "Got Results for ""<Filter>"" searching <Path> with -NoFiles and -Bare Options"   -TestCases $testCases3 {
        Param  ($filter, $path , $Kind,  $shortProperty, $longProperty)
        $i = $null
        $i = Get-IndexedItem -Filter $filter -path $path -NoFiles -bare -Recurse
        $i | Should not beNullOrEmpty
        $i[0].GetType().name                                            | Should not be FileInfo
        $i[0].GetType().name                                            | Should     be DataRow
        $i[0]."SYSTEM.KIND"                                             | Should     be $Kind
        $i[0].$shortProperty                                            | Should     beNullOrEmpty
        $i[0].$longProperty                                             | Should not beNullOrEmpty
    }
    it "Returned a [Table] object when run with -OutputVariable"                         -TestCases $testCases3 {
        Param  ($filter, $path , $Kind,  $shortProperty, $longProperty)
        Get-IndexedItem -Filter $filter -path $path  -NoFiles -bare -OutputVariable Table -Recurse
        $table                                                          | Should not beNullOrEmpty
        $table.GetType().name                                           | Should     be DataTable
        $table.Rows.Count                                               | Should     beGreaterThan 0
        $table.rows[1].$longProperty                                    | Should not beNullOrEmpty
    }
}
