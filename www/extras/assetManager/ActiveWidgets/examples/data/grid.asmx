<%@ WebService language="VB" class="grid" %>

Imports System
Imports System.Web.Services
Imports System.Xml.Serialization
Imports Microsoft.VisualBasic

public class company
    public ticker as string
    public name as string
    public marketcap as double
    public sales as double
    public employees as double
    public timestamp as date
end Class

<WebService(Namespace:="http://tempuri.org/")> Public Class grid
    <WebMethod> Public Function getCompanies() As company()
        Dim r(4) as company

        r(0) = new company
        r(0).ticker = "MSFT"
        r(0).name = "Microsoft Corporation"
        r(0).marketCap = 314571.156
        r(0).sales = 32187.000
        r(0).employees = 55000
        r(0).timestamp = Now

        r(1) = new company
        r(1).ticker = "ORCL"
        r(1).name = "Oracle Corporation"
        r(1).marketcap = 62615.27
        r(1).sales = 9519.00
        r(1).employees = 40650
        r(1).timestamp = Now

        r(2) = new company
        r(2).ticker = "SAP"
        r(2).name = "SAP AG (ADR)"
        r(2).marketcap = 40986.33
        r(2).sales = 8296.42
        r(2).employees = 28961
        r(2).timestamp = Now

        r(3) = new company
        r(3).ticker = "CA"
        r(3).name = "Computer Associates Inter"
        r(3).marketcap = 15606.34
        r(3).sales = 3164.00
        r(3).employees = 16000
        r(3).timestamp = Now

        r(4) = new company
        r(4).ticker = "ERTS"
        r(4).name = "Electronic Arts Inc."
        r(4).marketcap = 14490.90
        r(4).sales = 2503.73
        r(4).employees = 4000
        r(4).timestamp = Now

        Return r
    End Function
End Class
