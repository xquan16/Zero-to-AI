<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EditorSimulations.aspx.cs" Inherits="Zero_to_AI.Editor.EditorSimulations" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="sim-page">

    <div class="editor-hero" style="margin: 0 0 30px 0;">
        <h1>Editor • Simulations Manager</h1>
        <p>Manage simulation descriptions and status, then preview the live student experience. This editor workspace lets you keep simulation content clear, polished, and up to date.</p>
    </div>

    <div class="sim-section">
        <h3 class="sim-section-title"><i class="fas fa-sliders-h"></i> Simulation Management</h3>
        <p class="sim-section-sub">Preview each simulation, edit its description, update its status, and save changes directly to the database.</p>

        <div class="editor-sim-grid">

            <div class="sim-card">
                <div class="sim-card-head">
                    <div>
                        <h2 class="sim-card-title">Sorting Visualizer</h2>
                        <div class="sim-card-sub">Interactive simulation for sorting algorithms.</div>
                    </div>
                    <asp:Label ID="lblPill1" runat="server" CssClass="sim-pill" Text="Loading..." />
                </div>

                <div class="editor-box">
                    <div class="meta-row">
                        <div class="meta-item">
                            <span>Status</span>
                            <asp:DropDownList ID="ddlStatus1" runat="server" CssClass="form-control" Width="150px">
                                <asp:ListItem Text="Active" Value="Active" />
                                <asp:ListItem Text="Draft" Value="Draft" />
                                <asp:ListItem Text="Updated" Value="Updated" />
                            </asp:DropDownList>
                        </div>
                    </div>

                    <asp:TextBox ID="txtDesc1" runat="server" TextMode="MultiLine" CssClass="content-textarea" Height="120px" />

                    <div class="sim-toolbar" style="margin-top: 15px;">
                        <a class="sim-btn" href="../Member/Simulations.aspx" target="_blank">Preview / Run</a>
                        <asp:Button ID="btnSave1" runat="server" Text="Save Changes" CssClass="sim-btn sim-btn-primary" OnClick="btnSave1_Click" />
                    </div>

                    <asp:Label ID="lblMsg1" runat="server" CssClass="text-success" Visible="false" />
                </div>

                <div class="sim-hint">Editors can refine text shown across the platform and mark the simulation as Active, Draft, or Updated.</div>
            </div>

            <div class="sim-card">
                <div class="sim-card-head">
                    <div>
                        <h2 class="sim-card-title">RL Grid World</h2>
                        <div class="sim-card-sub">Real-time analytics simulation using Q-learning.</div>
                    </div>
                    <asp:Label ID="lblPill2" runat="server" CssClass="sim-pill" Text="Loading..." />
                </div>

                <div class="editor-box">
                    <div class="meta-row">
                        <div class="meta-item">
                            <span>Status</span>
                            <asp:DropDownList ID="ddlStatus2" runat="server" CssClass="form-control" Width="150px">
                                <asp:ListItem Text="Active" Value="Active" />
                                <asp:ListItem Text="Draft" Value="Draft" />
                                <asp:ListItem Text="Updated" Value="Updated" />
                            </asp:DropDownList>
                        </div>
                    </div>

                    <asp:TextBox ID="txtDesc2" runat="server" TextMode="MultiLine" CssClass="content-textarea" Height="120px" />

                    <div class="sim-toolbar" style="margin-top: 15px;">
                        <a class="sim-btn" href="../Member/Simulations.aspx" target="_blank">Preview / Run</a>
                        <asp:Button ID="btnSave2" runat="server" Text="Save Changes" CssClass="sim-btn sim-btn-primary" OnClick="btnSave2_Click" />
                    </div>

                    <asp:Label ID="lblMsg2" runat="server" CssClass="text-success" Visible="false" />
                </div>

                <div class="sim-hint">Use this card to maintain the description students see for reinforcement learning content.</div>
            </div>

            <div class="sim-card span-2">
                <div class="sim-card-head">
                    <div>
                        <h2 class="sim-card-title">Robot Path Planning</h2>
                        <div class="sim-card-sub">Student dashboard simulation for robotics-style navigation.</div>
                    </div>
                    <asp:Label ID="lblPill3" runat="server" CssClass="sim-pill" Text="Loading..." />
                </div>

                <div class="editor-box">
                    <div class="meta-row">
                        <div class="meta-item">
                            <span>Status</span>
                            <asp:DropDownList ID="ddlStatus3" runat="server" CssClass="form-control" Width="150px">
                                <asp:ListItem Text="Active" Value="Active" />
                                <asp:ListItem Text="Draft" Value="Draft" />
                                <asp:ListItem Text="Updated" Value="Updated" />
                            </asp:DropDownList>
                        </div>
                    </div>

                    <asp:TextBox ID="txtDesc3" runat="server" TextMode="MultiLine" CssClass="content-textarea" Height="120px" />

                    <div class="sim-toolbar" style="margin-top: 15px;">
                        <a class="sim-btn" href="../Member/Simulations.aspx" target="_blank">Preview / Run</a>
                        <asp:Button ID="btnSave3" runat="server" Text="Save Changes" CssClass="sim-btn sim-btn-primary" OnClick="btnSave3_Click" />
                    </div>

                    <asp:Label ID="lblMsg3" runat="server" CssClass="text-success" Visible="false" />
                </div>

                <div class="sim-hint">This simulation represents robotics and intelligent navigation. Editors can polish its presentation here.</div>
            </div>

        </div>
    </div>

</div>
</asp:Content>
