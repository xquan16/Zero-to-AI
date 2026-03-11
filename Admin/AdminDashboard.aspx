<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="Zero_to_AI.Admin.AdminDashboard" MaintainScrollPositionOnPostback="true" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

    <div class="dash-wrap">
        <div class="dash-header">
            <h1><asp:Label ID="lblWelcome" runat="server" Text="Command Center"></asp:Label></h1>
        </div>

        <div class="stat-grid">
            <a href="AdminSimulations.aspx" class="stat-card">
                <div class="stat-icon purple"><i class="fas fa-vr-cardboard"></i></div>
                <div class="stat-info"><h3 class="big-num"><asp:Label ID="lblAdSimTotal" runat="server">0</asp:Label></h3><span>Total Simulations</span></div>
            </a>
            <a href="AdminCourses.aspx" class="stat-card">
                <div class="stat-icon blue"><i class="fas fa-graduation-cap"></i></div>
                <div class="stat-info"><h3 class="big-num"><asp:Label ID="lblAdCourseTotal" runat="server">0</asp:Label></h3><span>Published Courses</span></div>
            </a>
            <a href="AdminMonitorQuiz.aspx" class="stat-card">
                <div class="stat-icon teal"><i class="fas fa-check-double"></i></div>
                <div class="stat-info"><h3 class="big-num"><asp:Label ID="lblAdQuizTotal" runat="server">0</asp:Label></h3><span>Question Bank</span></div>
            </a>
        </div>

        <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 30px;">
            
            <asp:UpdatePanel ID="upFeedback" runat="server"><ContentTemplate>
                <div class="panel" style="display: flex; flex-direction: column; height: 650px;">
                    <h2><i class="fas fa-comments"></i> Member Feedback</h2>
                    <asp:Label ID="lblMessage" runat="server" Visible="false" style="display:block; padding:10px; margin-bottom:15px; border-radius:8px; background:rgba(13,148,136,0.1); color:#0d9488; font-weight:bold;"></asp:Label>
                    
                    <div class="dash-tabs">
                        <asp:LinkButton ID="tabFbAll" runat="server" CssClass="tab-btn admin-active" OnClick="tabFb_Click" CommandArgument="All">All</asp:LinkButton>
                        <asp:LinkButton ID="tabFbUnread" runat="server" CssClass="tab-btn" OnClick="tabFb_Click" CommandArgument="Unread">Unread</asp:LinkButton>
                        <asp:LinkButton ID="tabFbRead" runat="server" CssClass="tab-btn" OnClick="tabFb_Click" CommandArgument="Read">Read</asp:LinkButton>
                    </div>
                    
                    <div style="overflow-y: auto; flex-grow: 1; padding-right: 10px;">
                        <asp:Repeater ID="rptAdminFeedback" runat="server" OnItemCommand="rptAdminFeedback_ItemCommand">
                            <ItemTemplate>
                                <div class="fb-item">
                                    <div class="fb-date">
                                        <strong><%# Eval("Username") %></strong> &bull; <%# Eval("Date", "{0:MMM dd, yyyy HH:mm}") %>
                                        <span style="float:right;" class='<%# Eval("Status").ToString() == "Unread" ? "text-danger" : "text-success" %>'><%# Eval("Status") %></span>
                                    </div>
                                    <div class="fb-msg"><%# Eval("Message") %></div>
                                    
                                    <asp:Panel runat="server" Visible='<%# Eval("Status").ToString() == "Unread" %>'>
                                        <asp:TextBox ID="txtAdminReply" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Type your reply here..."></asp:TextBox>
                                        <asp:Button ID="btnReply" runat="server" Text="Reply & Mark Read" CssClass="btn-admin" CommandName="Reply" CommandArgument='<%# Eval("FeedbackID") %>' style="padding: 6px 12px; font-size: 0.85rem;" />
                                    </asp:Panel>

                                    <asp:Panel runat="server" Visible='<%# Eval("Status").ToString() == "Read" %>' CssClass="fb-reply">
                                        <strong>Your Reply:</strong><br /><%# Eval("AdminReply") %>
                                    </asp:Panel>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Label ID="lblNoFeedbackAdmin" runat="server" Visible="false" Text="No feedback found for this filter." ForeColor="#94a3b8" Font-Bold="true"></asp:Label>
                    </div>
                </div>
            </ContentTemplate></asp:UpdatePanel>

            <asp:UpdatePanel ID="upUsers" runat="server"><ContentTemplate>
                <div class="panel" style="display: flex; flex-direction: column; height: 650px;">
                    <h2><i class="fas fa-user-shield"></i> User Management</h2>
                    
                    <div class="dash-tabs">
                        <asp:LinkButton ID="tabUserAll" runat="server" CssClass="tab-btn admin-active" OnClick="tabUser_Click" CommandArgument="All">All Users</asp:LinkButton>
                        <asp:LinkButton ID="tabUserEditors" runat="server" CssClass="tab-btn" OnClick="tabUser_Click" CommandArgument="Editors">Editors</asp:LinkButton>
                        <asp:LinkButton ID="tabUserMembers" runat="server" CssClass="tab-btn" OnClick="tabUser_Click" CommandArgument="Members">Members</asp:LinkButton>
                        <asp:LinkButton ID="tabUserBanned" runat="server" CssClass="tab-btn" OnClick="tabUser_Click" CommandArgument="Banned">Banned</asp:LinkButton>
                    </div>

                    <div style="display:flex; gap:10px; margin-bottom:15px;">
                        <asp:TextBox ID="txtSearchUser" runat="server" CssClass="form-control" placeholder="Search by Username..." style="margin-bottom:0;"></asp:TextBox>
                        <asp:Button ID="btnSearchUser" runat="server" Text="Search" CssClass="btn-admin" OnClick="btnSearchUser_Click" />
                    </div>
                    
                    <div style="overflow-y: auto; flex-grow: 1;">
                        <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="false" CssClass="admin-grid-table" Width="100%" GridLines="None" CellPadding="10" OnRowCommand="gvUsers_RowCommand">
                            <HeaderStyle CssClass="grid-header" HorizontalAlign="Left" />
                            <Columns>
                                <asp:BoundField DataField="Username" HeaderText="Username" ItemStyle-Font-Bold="true" />
                                <asp:BoundField DataField="Role" HeaderText="Role" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class='<%# Convert.ToBoolean(Eval("IsBanned")) ? "text-danger" : "text-success" %>'>
                                            <%# Convert.ToBoolean(Eval("IsBanned")) ? "Banned" : "Active" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:Button ID="btnToggleBan" runat="server" 
                                            Text='<%# Convert.ToBoolean(Eval("IsBanned")) ? "Unban" : "Ban" %>' 
                                            CommandName="ToggleBan" 
                                            CommandArgument='<%# Eval("UserID") %>' 
                                            CssClass='<%# Convert.ToBoolean(Eval("IsBanned")) ? "btn-primary" : "btn-danger" %>' 
                                            style="padding: 5px 10px; font-size: 0.8rem; border-radius:4px;" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <asp:Label ID="lblSearchError" runat="server" Visible="false" ForeColor="#e11d48"></asp:Label>
                    </div>
                </div>
            </ContentTemplate></asp:UpdatePanel>

        </div>
    </div>
</asp:Content>

