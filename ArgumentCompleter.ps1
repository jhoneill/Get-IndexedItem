function IndexColumnCompletion      {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

        $parameters = (Get-IndexedItem -List).shortname
        $parameters |  Where-Object { $_ -like "$wordToComplete*" } | Sort-Object |ForEach-Object {
            New-Object System.Management.Automation.CompletionResult "$_", "$_", ([System.Management.Automation.CompletionResultType]::ParameterValue) , $_
        }

}

function IndexColumnValueCompletion {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $ColumnName = $fakeBoundParameter['Where']
    [Void]$fakeBoundParameter.Remove("Where")
    if ($ColumnName) {
        (Get-IndexedItem -Value $ColumnName @fakeBoundParameter).$ColumnName  |
            Where-Object { $_ -like "$wordToComplete*" } | Sort-Object | ForEach-Object {
                    New-Object System.Management.Automation.CompletionResult "$_", "$_", ([System.Management.Automation.CompletionResultType]::ParameterValue) , $_
            }
    }
}

#In PowerShell 3 and 4 Register-ArgumentCompleter is part of TabExpansion ++. From V5 it is part of Powershell.core
if (Get-Command -ErrorAction SilentlyContinue -name Register-ArgumentCompleter) {
    Register-ArgumentCompleter -CommandName 'Get-IndexedItem' -ParameterName 'Where'    -ScriptBlock $Function:IndexColumnCompletion
    Register-ArgumentCompleter -CommandName 'Get-IndexedItem' -ParameterName 'Property' -ScriptBlock $Function:IndexColumnCompletion
    Register-ArgumentCompleter -CommandName 'Get-IndexedItem' -ParameterName 'Orderby'  -ScriptBlock $Function:IndexColumnCompletion
    Register-ArgumentCompleter -CommandName 'Get-IndexedItem' -ParameterName 'Value'    -ScriptBlock $Function:IndexColumnCompletion
    Register-ArgumentCompleter -CommandName 'Get-IndexedItem' -ParameterName 'EQ'       -ScriptBlock $Function:IndexColumnValueCompletion
}
