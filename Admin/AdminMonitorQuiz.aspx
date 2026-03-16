<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminMonitorQuiz.aspx.cs" Inherits="Zero_to_AI.Admin.AdminMonitorQuiz" Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="dashboard-container">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        
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

        <asp:UpdatePanel ID="upAI" runat="server" class="full-width">
            <ContentTemplate>
                <div class="ai-insight-card">
                    <div style="display:flex; justify-content: space-between; align-items: center;">
                        <h3 style="margin:0; border:none; padding:0; color:white;">✨ AI Command Center</h3>
                        <div style="display:flex; gap: 10px;">
                            <asp:Button ID="btnGenerateReport" runat="server" Text="📊 System Report" OnClick="btnGenerateReport_Click" style="background:#fff; color:#764ba2; border:none; padding:10px 15px; border-radius:8px; cursor:pointer; font-weight:bold; transition:0.3s;" />
                            <asp:Button ID="btnFindAtRisk" runat="server" Text="🎯 Find At-Risk Student" OnClick="btnFindAtRisk_Click" style="background:#ff7675; color:#fff; border:none; padding:10px 15px; border-radius:8px; cursor:pointer; font-weight:bold; transition:0.3s; box-shadow: 0 4px 10px rgba(255,118,117,0.4);" />
                        </div>
                    </div>

                    <div class="ai-result-box">
                        <asp:Label ID="lblAIReport" runat="server" Text="Select an AI action above to analyze the database."></asp:Label>

                        <asp:Panel ID="pnlEmailDraft" runat="server" Visible="false" style="margin-top:15px; border-top:2px dashed #eee; padding-top:15px;">
                            <div style="font-weight:bold; color:#d63031; margin-bottom:10px; font-size:16px;">
                                <asp:Label ID="lblAtRiskWarning" runat="server"></asp:Label>
                            </div>

                            <div style="margin-bottom: 15px; background: #f0f8ff; padding: 10px; border-radius: 8px;">
                                <span style="font-weight: bold; color: #0984e3; font-size: 14px;">✉️ Send To: </span>
                                <asp:TextBox ID="txtRecipientEmail" runat="server" placeholder="student@gmail.com" style="width: 70%; padding: 6px; border: 1px solid #ccc; border-radius: 4px; outline: none;"></asp:TextBox>
                            </div>
                            <asp:TextBox ID="txtEmailDraft" runat="server" TextMode="MultiLine" Rows="7" style="width:100%; border-radius:8px; padding:15px; border:1px solid #ccc; font-family:inherit; font-size:14px; line-height:1.5; outline:none; box-sizing:border-box; background:#f9f9f9;"></asp:TextBox>

                            <div style="text-align:right; margin-top:12px;">
                                <asp:Button ID="btnSendEmail" runat="server" Text="🚀 Send REAL Email" OnClick="btnSendEmail_Click" style="background:#0984e3; color:white; padding:10px 20px; border:none; border-radius:6px; cursor:pointer; font-weight:bold; transition:0.2s;" />
                            </div>
                        </asp:Panel>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>

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