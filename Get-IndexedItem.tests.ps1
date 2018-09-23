describe "Get-IndexedItem" {
    $testCases1 =  @(
       @{  ContainsText  = 'Stingray' ; kind = 'Picture'; keyword='Portfolio'; Path="~"}
    )
    $TestCases2 = @(
        @{ path =([system.environment]::GetFolderPath( [system.environment+specialFolder]::MyPictures )); keyword="PortFolio" }
    )
    $testCases3 =  @(
       @{ Filter = "System.Kind = 'Music' AND AlbumArtist like '%' "; path= "C:\Users" }
    )
    it "Returned at least one <kind> file from <path> containing <ContainsText> with keyword <keyword>" -TestCases $testCases1 {
        Param ($containsText,$kind,$keyword,$path )
        $i = Get-IndexedItem -Filter "Contains(*,'$containsText')", "kind = '$kind'", "keywords='$Keyword'" -path $path -recurse
        $i | should not beNullOrEmpty
        $i[0].GetType().name | should be FileInfo
        $i[0].Keyword -contains $keyword | should be $true
    }
    it "Got the same result with shortened syntax" -TestCases $testCases1 {
        Param ($containsText,$kind,$keyword,$path )
        $i = $null
        $i = Get-IndexedItem $containsText, "kind=$kind", "keyword=$Keyword"  -recurse $path
        $i | should not beNullOrEmpty
        $i[0].GetType().name | should be FileInfo
        $i[0].Keyword -contains $keyword | should be $true
        $f = $i | Select-Object -first 1 | copy-item -Destination $env:TEMP -PassThru
        $f | should not beNullOrEmpty
        $f.name | should be $i[0].name
        {remove-item $f } | should not throw
    }
    it "Found keywords including <keyword> in <path>" -TestCases $testCases2 {
        Param ($Path , $keyword)
        $k = Get-IndexedItem -Value Keyword -Path $path -Recurse
        $k | should not beNullOrEmpty
        $k.Keyword -contains $keyword | should be $true
        $i = $null
        $i = Get-IndexedItem -Path $path -Recurse -Where Keyword -eq $keyword
        $I | should not beNullOrEmpty
        $i[0].keywords -contains $keyword | should be $true
    }

    it "Got Results for <Filter> for current folder with -NoFiles option" -TestCases $testCases3 {
        Param ($filter, $path )
        $i = $null
        Push-Location $path
        $i = Get-IndexedItem -Filter $filter -path $null -NoFiles
        Pop-Location
        $i | should not beNullOrEmpty
        $i[0].GetType().name | should not be FileInfo
        $i[0].GetType().name | should not be DataRow
        $i[0].KIND | should be music
        $i[0].ALBUMARTIST | should not beNullOrEmpty
        $i[0]."SYSTEM.MUSIC.ALBUMARTIST" | should beNullOrEmpty
    }
    it "Got Results for <Filter> for current folder with -NoFiles and -Bare Options" -TestCases $testCases3 {
        Param ($filter, $path )
        $i = $null
        Push-Location $path
        $i = Get-IndexedItem -Filter $filter -path $null -NoFiles -bare
        Pop-Location
        $i | should not beNullOrEmpty
        $i[0].GetType().name | should not be FileInfo
        $i[0].GetType().name | should be DataRow
        $i[0]."SYSTEM.KIND" | should be music
        $i[0].ALBUMARTIST | should   beNullOrEmpty
        $i[0]."SYSTEM.MUSIC.ALBUMARTIST" | should not beNullOrEmpty
    }
    it "Got Results for <Filter> with -NoFiles and -Bare Options" -TestCases $testCases3 {
        Param ($filter, $path )
        $i = $null
        Push-Location $path
        $i = Get-IndexedItem -Filter $filter -path $null -NoFiles -bare
        Pop-Location
        $i | should not beNullOrEmpty
        $i[0].GetType().name | should not be FileInfo
        $i[0].GetType().name | should be DataRow
        $i[0]."SYSTEM.KIND" | should be music
        $i[0].ALBUMARTIST | should   beNullOrEmpty
        $i[0]."SYSTEM.MUSIC.ALBUMARTIST" | should not beNullOrEmpty
    }
    it "Returned a table when run with -OutputVariable" -TestCases $testCases3 {
        Param ($filter, $path )
        Get-IndexedItem -Filter $filter -path $path  -NoFiles -bare -OutputVariable Table
        $table | should not beNullOrEmpty
        $table.GetType().name | should be DataTable
        $table.Rows.Count |  should beGreaterThan 0
        $table.rows[1]."SYSTEM.MUSIC.ALBUMARTIST" | should not beNullOrEmpty
    }
}

#Get-IndexedItem -Filter "System.Kind = 'Music' AND AlbumArtist like '%'  " -path $null -NoFiles | Group-Object -NoElement -Property "AlbumArtist" | Sort-Object -Descending -property count
#Get-IndexedItem -Filter "Kind=music","AlbumArtist like '%' ","DateModified>'2018-07-12'" -NoFiles -Recurse  | Select-Object -ExpandProperty name

#Get-IndexedItem -path c:\ -recurse  -Filter cameramaker=pentax* -Property focallength | Group-Object @{e={$_.focallength -as [int]}} -NoElement | Sort-Object -property @{e={[double]$_.name}} |Where-Object {$_.name} | export-excel -ExcludeProperty group,name -ColumnChart -Now
