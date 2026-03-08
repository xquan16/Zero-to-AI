<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminMonitorQuiz.aspx.cs" Inherits="Zero_to_AI.Admin.AdminMonitorQuiz" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="dashboard-container">
        
        <div class="card">
            <h3>📊 Questions Breakdown</h3>
            
            <ul class="topic-list">
                <asp:Literal ID="litTopicStats" runat="server"></asp:Literal>
            </ul>

            <div style="height: 200px; width: 100%; display: flex; justify-content: center;">
                <canvas id="questionsChart"></canvas>
            </div>
        </div>

        <div class="card">
            <h3>📈 System Quick Stats</h3>
            <div class="stat-box">
                Total Questions: <b><asp:Label ID="lblTotalQ" runat="server" Text="0"></asp:Label></b><br />
                Total Logs: <b><asp:Label ID="lblTotalLogs" runat="server" Text="0"></asp:Label></b><br />
                Last Activity: <b><asp:Label ID="lblLastUpdate" runat="server" Text="No activity yet"></asp:Label></b>
            </div>
        </div>

        <div class="card full-width">
            <h3>📝 Editor Audit Log</h3>
            <asp:GridView ID="gvLogs" runat="server" AutoGenerateColumns="False" 
                style="width: 100%; border-collapse: collapse;" GridLines="Horizontal" BorderColor="#eee" CellPadding="12">
                <HeaderStyle BackColor="#f8f9fa" Font-Bold="True" HorizontalAlign="Left" ForeColor="#333" />
                <RowStyle />
                <Columns>
                    <asp:BoundField DataField="LogID" HeaderText="ID" ItemStyle-Width="50px" />
                    <asp:BoundField DataField="UserName" HeaderText="Editor" ItemStyle-Font-Bold="true" ItemStyle-ForeColor="#e74c3c" />
                    <asp:BoundField DataField="ActionType" HeaderText="Action" ItemStyle-Font-Bold="true" ItemStyle-ForeColor="#3498db" />
                    <asp:BoundField DataField="Description" HeaderText="Details" />
                    <asp:BoundField DataField="ActionDate" HeaderText="Time" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}" />
                </Columns>
            </asp:GridView>
            
            <asp:Label ID="lblNoLogs" runat="server" Visible="false" 
                Text="Table is empty. Go to Editor page and change something to see logs here!" 
                ForeColor="#999" Font-Italic="true" style="display:block; margin-top:15px; text-align:center;">
            </asp:Label>
        </div>
    </div>


    <script>
        document.addEventListener("DOMContentLoaded", function () {
            var ctx = document.getElementById('questionsChart').getContext('2d');

            // Gain backend data
            var chartLabels = [<%= ChartLabels %>]; 
            var chartData = [<%= ChartData %>];

            // Draw chart
            if (chartLabels.length > 0) {
                new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: chartLabels,
                        datasets: [{
                            data: chartData,
                            backgroundColor: ['#3498db', '#e74c3c', '#2ecc71'],
                            borderWidth: 2
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false, 
                        plugins: { legend: { position: 'right' } }
                    }
                });
            }
        });
    </script>
</asp:Content>