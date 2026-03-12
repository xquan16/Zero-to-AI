<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminManageUsers.aspx.cs" Inherits="Zero_to_AI.Admin.AdminManageUsers" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager runat="server"></asp:ScriptManager>
    
    <div class="dash-wrap">
        <div style="margin-bottom: 20px;">
            <a href="AdminDashboard.aspx" class="btn-manager"><i class="fas fa-arrow-left"></i> Back</a>
        </div>
        
        <div class="dash-header top-actions">
            <h1><i class="fas fa-users-cog"></i> Full User Management</h1>
            <asp:LinkButton ID="btnShowAddUser" runat="server" CssClass="btn-admin" OnClick="btnShowAddUser_Click">
                <i class="fas fa-plus"></i> Add New User
            </asp:LinkButton>
        </div>
        
        <asp:UpdatePanel ID="upMain" runat="server"><ContentTemplate>
            <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="lbl-alert"></asp:Label>
            
            <asp:Panel ID="pnlUserForm" runat="server" Visible="false" CssClass="panel panel-highlight">
                <h2><asp:Label ID="lblFormTitle" runat="server" Text="Add New User"></asp:Label></h2>
                <asp:HiddenField ID="hfEditUserID" runat="server" />
                
                <div class="form-row-grid">
                    <div>
                        <label>First Name</label>
                        <asp:TextBox ID="txtFirst" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div>
                        <label>Last Name</label>
                        <asp:TextBox ID="txtLast" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div>
                        <label>Username</label>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div>
                        <label>Email</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email"></asp:TextBox>
                    </div>
                    <div>
                        <label>Role</label>
                        <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-control">
                            <asp:ListItem Text="Member" Value="Member"></asp:ListItem>
                            <asp:ListItem Text="Editor" Value="Editor"></asp:ListItem>
                            <asp:ListItem Text="Admin" Value="Admin"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div>
                        <label>Password <small class="text-muted">(Leave blank to keep existing if editing)</small></label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                    </div>
                </div>
                
                <div class="form-actions-right">
                    <asp:Button ID="btnCancelForm" runat="server" Text="Cancel" CssClass="btn-manager" OnClick="btnCancelForm_Click" />
                    <asp:Button ID="btnSaveUser" runat="server" Text="Save User" CssClass="btn-admin" OnClick="btnSaveUser_Click" />
                </div>
            </asp:Panel>

            <div class="panel">
                <div class="top-actions">
                    <div class="dash-tabs filter-control">
                        <asp:LinkButton ID="tabAll" runat="server" CssClass="tab-btn admin-active" CommandArgument="All" OnClick="tabStatus_Click">All Users</asp:LinkButton>
                        <asp:LinkButton ID="tabActive" runat="server" CssClass="tab-btn" CommandArgument="Active" OnClick="tabStatus_Click">Active</asp:LinkButton>
                        <asp:LinkButton ID="tabBanned" runat="server" CssClass="tab-btn" CommandArgument="Banned" OnClick="tabStatus_Click">Banned</asp:LinkButton>
                    </div>
                    
                    <div class="filter-group">
                        <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="form-control filter-control" AutoPostBack="true" OnSelectedIndexChanged="ddlRoleFilter_SelectedIndexChanged">
                            <asp:ListItem Text="All Roles" Value="All"></asp:ListItem>
                            <asp:ListItem Text="Editor" Value="Editor"></asp:ListItem>
                            <asp:ListItem Text="Member" Value="Member"></asp:ListItem>
                        </asp:DropDownList>
                        
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control filter-control" placeholder="Search Username..."></asp:TextBox>
                        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn-admin" OnClick="btnSearch_Click" />
                    </div>
                </div>

                <div class="table-responsive">
                    <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="false" CssClass="admin-grid-table" Width="100%" GridLines="None" CellPadding="10" OnRowCommand="gvUsers_RowCommand" OnRowDataBound="gvUsers_RowDataBound">
                        <HeaderStyle CssClass="grid-header" HorizontalAlign="Left" />
                        <Columns>
                            <asp:BoundField DataField="Username" HeaderText="Username" ItemStyle-Font-Bold="true" ItemStyle-CssClass="text-left" />
                            <asp:BoundField DataField="Role" HeaderText="Role" ItemStyle-CssClass="text-left" />
                            <asp:BoundField DataField="CreatedAt" HeaderText="Created Date" DataFormatString="{0:MMM dd, yyyy}" ItemStyle-CssClass="text-left" />
                            
                            <asp:TemplateField HeaderText="Status" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left">
                                <ItemTemplate>
                                    <asp:Label ID="lblStatus" runat="server" 
                                        Text='<%# Convert.ToBoolean(Eval("IsBanned")) ? "Banned" : "Active" %>' 
                                        CssClass='<%# Convert.ToBoolean(Eval("IsBanned")) ? "text-danger text-left" : "text-success text-left" %>'>
                                    </asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>

                           <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:Button ID="btnToggleBan" runat="server" 
                                        Text='<%# Convert.ToBoolean(Eval("IsBanned")) ? "Unban" : "Ban" %>' 
                                        CommandName="ToggleBan" 
                                        CommandArgument='<%# Eval("UserID") %>' 
                                        CssClass='<%# Convert.ToBoolean(Eval("IsBanned")) ? "btn-primary btn-grid-action" : "btn-danger btn-grid-action" %>' />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Edit">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditUser" CommandArgument='<%# Eval("UserID") %>' CssClass="btn-edit-user" ToolTip="Edit User">
                                        <i class="fas fa-pen"></i> Edit
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                    <asp:Label ID="lblSearchError" runat="server" Visible="false" ForeColor="#e11d48"></asp:Label>
                </div>
            </div>
        </ContentTemplate></asp:UpdatePanel>
    </div>
</asp:Content>
