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

            <div class="chart-container">
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
                CssClass="admin-grid-table" GridLines="None" CellPadding="12">
                <HeaderStyle CssClass="grid-header" />
                <RowStyle />
                <Columns>
                    <asp:BoundField DataField="LogID" HeaderText="ID" ItemStyle-Width="50px" />
                    <asp:BoundField DataField="UserName" HeaderText="Editor" ItemStyle-Font-Bold="true" ItemStyle-ForeColor="#e74c3c" />
                    <asp:BoundField DataField="ActionType" HeaderText="Action" ItemStyle-Font-Bold="true" ItemStyle-ForeColor="#3498db" />
                    <asp:BoundField DataField="ActionDetails" HeaderText="Details" />
                    <asp:BoundField DataField="ActionDate" HeaderText="Time" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}" />
                </Columns>
            </asp:GridView>
            
            <asp:Label ID="lblNoLogs" runat="server" Visible="false" 
                Text="Table is empty. Go to Editor page and change something to see logs here!" 
                CssClass="empty-msg">
            </asp:Label>
        </div>
    </div>

    <div class="dashboard-container"> <div class="card">
        <h3>📊 Average Score per Topic</h3>
        <ul class="topic-list">
            <asp:Literal ID="litStudentChartStats" runat="server"></asp:Literal>
        </ul>
        <asp:Label ID="lblNoChart2Data" runat="server" Visible="false" Text="No quiz scores yet." CssClass="empty-msg"></asp:Label>
            
        <div class="chart-container mt-20">
            <canvas id="studentChart"></canvas>
        </div>
    </div>

    <div class="card">
        <h3>🎓 Recent Performances</h3>
        <div class="filter-bar-mini">
            <asp:Label ID="lblFilter" runat="server" Text="Filter:" Font-Bold="true"></asp:Label>
            <asp:DropDownList ID="ddlFilterTopic" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterTopic_SelectedIndexChanged" CssClass="filter-dropdown"></asp:DropDownList>
        </div>

        <div class="table-scroll-wrap">
            <asp:GridView ID="gvStudentScores" runat="server" AutoGenerateColumns="False" 
                CssClass="admin-grid-table small-text" GridLines="None" CellPadding="8">
                    
                <HeaderStyle CssClass="sticky-header grid-header" />
                <RowStyle />
                <Columns>
                    <asp:BoundField DataField="StudentName" HeaderText="Student" ItemStyle-Font-Bold="true" ItemStyle-ForeColor="#2ecc71" />
                    <asp:BoundField DataField="QuizTitle" HeaderText="Topic" />
                    <asp:BoundField DataField="Score" HeaderText="Score" ItemStyle-Font-Bold="true" ItemStyle-ForeColor="#e67e22" />
                </Columns>
            </asp:GridView>
        </div>
        <asp:Label ID="lblNoScores" runat="server" Visible="false" Text="No records found." CssClass="empty-msg"></asp:Label>
    </div></div>

    <script>
        document.addEventListener("DOMContentLoaded", function () {

            // --- 第 1 个图表 (题库甜甜圈图) ---
            var chart1Labels = [<%= ChartLabels %>];
            var chart1Data = [<%= ChartData %>];
            
            if (chart1Labels.length > 0) {
                var ctx1 = document.getElementById('questionsChart').getContext('2d');
                new Chart(ctx1, {
                    type: 'doughnut',
                    data: {
                        labels: chart1Labels,
                        datasets: [{
                            data: chart1Data,
                            backgroundColor: ['#3498db', '#9b59b6', '#34495e'],
                            borderWidth: 2
                        }]
                    },
                    options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'right' } } }
                });
            }

            // --- 第 2 个图表 (学生成绩柱状图) ---
            var chart2Labels = [<%= StudentChartLabels %>]; 
            var chart2Data = [<%= StudentChartData %>];

            if (chart2Labels.length > 0) {
                var ctx2 = document.getElementById('studentChart').getContext('2d');
                new Chart(ctx2, {
                    type: 'bar', // 👈 变成柱状图
                    data: {
                        labels: chart2Labels,
                        datasets: [{
                            label: 'Average Score',
                            data: chart2Data,
                            backgroundColor: ['#e74c3c', '#f1c40f', '#2ecc71'],
                            borderRadius: 5 // 圆角柱子
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: { legend: { display: false } }, // 隐藏多余的图例
                        scales: {
                            y: {
                                beginAtZero: true,
                                max: 100 // 把满分定为 100
                            }
                        }
                    }
                });
            }
        });
    </script>
</asp:Content>