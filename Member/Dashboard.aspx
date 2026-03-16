<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Zero_to_AI.Member.Dashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dash-wrap">
        <div class="dash-header">
            <h1><asp:Label ID="lblWelcome" runat="server" Text="Welcome back!"></asp:Label></h1>
        </div>

        <asp:Label ID="lblMessage" runat="server" Visible="false" style="display:block; padding:15px; margin-bottom:20px; border-radius:8px; background:rgba(13,148,136,0.1); color:#0d9488; border:1px solid rgba(13,148,136,0.3); font-weight:bold;"></asp:Label>

        <div class="stat-grid">
            <a href="~/Member/Simulations.aspx" runat="server" class="stat-card">
                <div class="stat-icon purple"><i class="fas fa-gamepad"></i></div>
                <div class="stat-info"><h3 class="big-num"><asp:Label ID="lblMemSims" runat="server">0</asp:Label></h3><span>Simulations Cleared</span></div>
            </a>
            <a href="~/Member/Courses.aspx" runat="server" class="stat-card">
                <div class="stat-icon blue"><i class="fas fa-book-reader"></i></div>
                <div class="stat-info"><h3 class="big-num"><asp:Label ID="lblMemCourses" runat="server">0</asp:Label></h3><span>Courses Completed</span></div>
            </a>
            <a href="~/Member/QuizTopic.aspx" runat="server" class="stat-card">
                <div class="stat-icon teal"><i class="fas fa-brain"></i></div>
                <div class="stat-info"><h3 class="big-num"><asp:Label ID="lblMemQuizzes" runat="server">0%</asp:Label></h3><span>Avg Quiz Score</span></div>
            </a>
        </div>

        <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 30px;">
            <div class="panel">
                <h2><i class="fas fa-paper-plane"></i> Send Feedback</h2>
                <asp:TextBox ID="txtFeedbackMsg" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="Tell the admin what you think, report a bug, or request a topic!"></asp:TextBox>
                <asp:Button ID="btnSendFeedback" runat="server" Text="Send to Admin" CssClass="btn-primary" OnClick="btnSendFeedback_Click" />
            </div>
            <div class="panel" style="max-height: 400px; overflow-y: auto;">
                <h2><i class="fas fa-inbox"></i> My Feedback Inbox</h2>
                <asp:Repeater ID="rptMyFeedback" runat="server">
                    <ItemTemplate>
                        <div class="fb-item">
                            <div class="fb-date"><i class="far fa-clock"></i> <%# Eval("Date", "{0:MMM dd, yyyy HH:mm}") %></div>
                            <div class="fb-msg"><%# Eval("Message") %></div>
                            <asp:Panel runat="server" Visible='<%# Eval("AdminReply") != DBNull.Value %>' CssClass="fb-reply">
                                <strong>Admin Reply:</strong><br />
                                <%# Eval("AdminReply") %>
                            </asp:Panel>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Label ID="lblNoFeedbackMem" runat="server" Visible="false" Text="You haven't sent any feedback yet." ForeColor="#94a3b8"></asp:Label>
            </div>
        </div>
    </div>
</asp:Content>
