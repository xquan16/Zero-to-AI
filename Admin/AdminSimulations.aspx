<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminSimulations.aspx.cs" Inherits="Zero_to_AI.Admin.AdminSimulations" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="sim-page">

    <div class="admin-hero" style="margin: 0 0 30px 0;">
        <h1>Admin • Simulations Analytics</h1>
        <p>Admin-only dashboard for simulation usage. View total runs, unique users, most used simulation, user activity, and simulation breakdown.</p>
    </div>

    <div class="sim-section">
        <h3 class="sim-section-title"><i class="fas fa-chart-line"></i> Real-Time Analytics</h3>
        <p class="sim-section-sub">Filter simulation activity by date and simulation, then review usage insights across the platform.</p>

        <div class="editor-sim-grid">

            <div class="sim-card">
                <div class="sim-card-head">
                    <div>
                        <h2 class="sim-card-title">Usage Overview</h2>
                        <div class="sim-card-sub">Filter simulation data and view top-level usage metrics.</div>
                    </div>
                    <div class="sim-pill">Admin</div>
                </div>

                <div class="sim-toolbar">
                    <label>From</label>
                    <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date" CssClass="form-control" Width="130px" />

                    <label>To</label>
                    <asp:TextBox ID="txtToDate" runat="server" TextMode="Date" CssClass="form-control" Width="130px" />

                    <label>Simulation</label>
                    <asp:DropDownList ID="ddlSimulations" runat="server" CssClass="form-control" Width="150px" />

                    <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="sim-btn sim-btn-primary" OnClick="btnRefresh_Click" style="margin-left: auto;" />
                </div>

                <div class="editor-box">
                    <div class="sim-stats-row">
                        <div class="sim-pill">Total Runs: <asp:Label ID="lblTotalRuns" runat="server" Text="0" /></div>
                        <div class="sim-pill">Unique Users: <asp:Label ID="lblUniqueUsers" runat="server" Text="0" /></div>
                        <div class="sim-pill">Most Used: <asp:Label ID="lblMostUsed" runat="server" Text="—" /></div>
                    </div>
                    <asp:Label ID="lblStatus" runat="server" CssClass="text-success" Visible="false" style="display:block; margin-top:10px;" />
                </div>
                <div class="sim-hint">Use date filters to review platform activity over time.</div>
            </div>

            <div class="sim-card">
                <div class="sim-card-head">
                    <div>
                        <h2 class="sim-card-title">Runs by Simulation</h2>
                        <div class="sim-card-sub">See how often each simulation was used.</div>
                    </div>
                    <div class="sim-pill">Breakdown</div>
                </div>

                <div class="editor-box" style="overflow-x: auto; padding: 0;">
                    <table class="completions-table">
                        <thead>
                            <tr>
                                <th>Simulation</th>
                                <th>Runs</th>
                                <th>Last Run</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="repRunsBySimulation" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Eval("simulationName") %></td>
                                        <td><%# Eval("runCount") %></td>
                                        <td><%# Eval("lastRun") %></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>

                <div class="sim-hint">This shows which simulations are most used within the selected range.</div>
            </div>

        </div>
    </div>

    <div class="sim-section">
        <h3 class="sim-section-title"><i class="fas fa-users"></i> Student Dashboard</h3>
        <p class="sim-section-sub">Review user participation and recent simulation activity.</p>

        <div class="editor-sim-grid">

            <div class="sim-card">
                <div class="sim-card-head">
                    <div>
                        <h2 class="sim-card-title">Top Users</h2>
                        <div class="sim-card-sub">Users with the most simulation runs.</div>
                    </div>
                    <div class="sim-pill">Users</div>
                </div>

                <div class="editor-box" style="overflow-x: auto; padding: 0;">
                    <table class="completions-table">
                        <thead>
                            <tr>
                                <th>User</th>
                                <th>Runs</th>
                                <th>Last Run</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="repTopUsers" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Eval("userDisplay") %></td>
                                        <td><%# Eval("runCount") %></td>
                                        <td><%# Eval("lastRun") %></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>

                <div class="sim-hint">This helps identify active students and simulation engagement.</div>
            </div>

            <div class="sim-card">
                <div class="sim-card-head">
                    <div>
                        <h2 class="sim-card-title">Recent Runs</h2>
                        <div class="sim-card-sub">Most recent simulation activity across the system.</div>
                    </div>
                    <div class="sim-pill">Activity</div>
                </div>

                <div class="editor-box" style="overflow-x: auto; padding: 0;">
                    <table class="completions-table">
                        <thead>
                            <tr>
                                <th>Time</th>
                                <th>User</th>
                                <th>Simulation</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="repRecentRuns" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Eval("runTime") %></td>
                                        <td><%# Eval("userDisplay") %></td>
                                        <td><%# Eval("simulationName") %></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>

                <div class="sim-hint">Use this feed to confirm that simulation logging is working correctly.</div>
            </div>

        </div>
    </div>

</div>
</asp:Content>
