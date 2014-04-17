﻿//-----------------------------------------------------------------------
// <copyright file="GroupHelper.cs" company="Microsoft">
//     Copyright (c) Microsoft Corporation.  All rights reserved.
// </copyright>
// <author>v-mifu@microsoft.com</author>
// <description>Test cases group operators: to start DSC omiserver before run and stop DSC omiserver after run.</description>
//-----------------------------------------------------------------------

namespace DSC
{
    using System;
    using Infra.Frmwrk;

    public class GroupHelper : ISetup, ICleanup
    {
        private SshHelper sshHelper;

        string getPidCommand;
        string killCommand;
        string startOMIcommand;
        string exportDSCPathCommand;

        public void Setup(IContext ctx)
        {
            ctx.Alw("GroupHelper Setup Begin");

            string nxHostName = ctx.Records.GetValue("nxHostName");
            string nxUsername = ctx.Records.GetValue("nxUsername");
            string nxpassword = ctx.Records.GetValue("nxpassword");
            int nxPort = Int32.Parse(ctx.Records.GetValue("nxPort"));
            Console.WriteLine("Newing");
            sshHelper = new SshHelper(nxHostName, nxUsername, nxpassword, nxPort);
            Console.WriteLine("Newed");
            getPidCommand = ctx.Records.GetValue("getPid");
            killCommand = ctx.Records.GetValue("kill");
            exportDSCPathCommand = ctx.Records.GetValue("exportDSCPath");
            startOMIcommand = ctx.Records.GetValue("startOMI");
            
            // TO-DO: Install DSC Providers.

            // Kill current omiserver process, start omiserver process of DSC.
            string pid;
            sshHelper.Execute(getPidCommand, out pid);

            if (!String.IsNullOrWhiteSpace(pid))
            {
                sshHelper.Execute(String.Format("{0} {1}", killCommand, pid));
                ctx.Alw(String.Format("Kill old omiserver process '{0}'", pid));
            }

            sshHelper.Execute(String.Format("{0};{1}", exportDSCPathCommand, startOMIcommand));
            ctx.Alw(String.Format("Export DSC_PATH : '{0}'", exportDSCPathCommand));
            ctx.Alw(String.Format("Start DSC omiserver : '{0}'", startOMIcommand));

            ctx.Alw("GroupHelper Setup End");
        }

        public void Cleanup(IContext ctx)
        {
            ctx.Alw("GroupHelper Cleanup Begin");
            
            // Stop omiserver process of DSC.
            string pid;
            sshHelper.Execute(getPidCommand, out pid);

            if (!String.IsNullOrWhiteSpace(pid))
            {
                sshHelper.Execute(String.Format("{0} {1}", killCommand, pid));
                ctx.Alw(String.Format("Kill DSC omiserver process '{0}'", pid));
            }

            sshHelper.Dispose();

            ctx.Alw("GroupHelper Cleanup End");

            // TO-DO: Uninstall DSC Providers.
        }
    }
}
