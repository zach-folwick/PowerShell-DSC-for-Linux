﻿//-----------------------------------------------------------------------
// <copyright file="nxIPAddressTest.cs" company="Microsoft">
//     Copyright (c) Microsoft Corporation.  All rights reserved.
// </copyright>
// <author>v-fridax@microsoft.com</author>
// <description>Inherit from BaseProviderTest, override Setup(IContext ctx). </description>
//-----------------------------------------------------------------------

using System;
using System.Text;
using Infra.Frmwrk;
using System.Collections.Generic;

namespace DSC
{
    class nxIPAddressTest : ProviderTestBase
    {
        private string interfaceName;
        private bool isDU;
        public override void Setup(IContext ctx)
        {
            ctx.Alw("nxIPAddressTest Setup Begin.");

            mofHelper = new EnvironmentMofHelper();

            string initalSet = ctx.Records.GetValue("initialSet");
            interfaceName = ctx.Records.GetValue("interfaceName");

            string nxHostName = ctx.Records.GetValue("nxHostName");
            string nxUsername = ctx.Records.GetValue("nxUsername");
            string nxpassword = ctx.Records.GetValue("nxpassword");
            int nxPort = Int32.Parse(ctx.Records.GetValue("nxPort"));

            // Open SSH.
            sshHelper = new SshHelper(nxHostName, nxUsername, nxpassword, nxPort);
            string sysinfo = string.Empty;
            isDU = false;

            try
            {
                // Store the orignal hostname.
                sshHelper.Execute("cat /proc/version", out sysinfo);
                if (sysinfo.Contains("Ubuntu") || sysinfo.Contains("Debian"))
                {
                    isDU = true;
                }
                initializeCmd = GetInitializeCmd(initalSet, isDU);
                finalizeCmd = GetFinalizeCmd(isDU);

                // Initialize Service State.
                ctx.Alw(String.Format("Initilize Linux state : '{0}'", initializeCmd));
                
                sshHelper.Execute(initializeCmd);
                
            }
            catch (Exception ex)
            {
                ctx.Alw(ex.Message);
            }

            ctx.Alw("nxIPAddressTest Setup End.");
        }


        // Check Linux service's state and enabled state.
        protected override void VerifyLinuxState(IContext ctx)
        {
            string verification = ctx.Records.GetValue("verification");
            if (String.IsNullOrEmpty(verification))
            {
                return;
            }
           
            var verificationMap = ConvertStringToPropMap(verification);
            string interf = string.Empty;
            string configVal = string.Empty;

            if (!verificationMap.ContainsKey("InterfaceName"))
            {
                interf = interfaceName;
            }
            else
            {
                interf = verificationMap["InterfaceName"];
            }

            try
            {
                sshHelper.Execute("ifconfig " + interf, out configVal);
            }
            catch { }

            // Get AddressFamily type, the default is "IPV4"
            string addrFamily = "inet";
            if (verificationMap.ContainsKey("AddressFamily"))
            {
                if (verificationMap["AddressFamily"].ToLower() == "ipv6") ;
                {
                    addrFamily = "inet6";
                }
            }

            // Check IPAddress and AddressFamily.
            if (verificationMap.ContainsKey("IPAddress"))
            {
                string tmpAddr = GetConfigVal("ifconfig " + interfaceName, addrFamily + " addr", 1);
                if (!verificationMap["IPAddress"].Equals(
                    tmpAddr, StringComparison.InvariantCultureIgnoreCase))
                {
                    throw new VarFail(String.Format(
                        "'{0}' Service State : expect - '{1}', actual - '{2}'",
                        "IPAddress", verificationMap["IPAddress"], tmpAddr));
                }
            }
            
            if (verificationMap.ContainsKey("BootProtocol"))
            {
                //TBD: check ifcfg-ethx or interfaces?
                
            }

            // Check DefaultGateway
            if (verificationMap.ContainsKey("DefaultGateway"))
            {
                string tmpDefaultGW = GetConfigVal("ip route", "default", 2);
                if (!verificationMap["DefaultGateway"].Equals(
                    tmpDefaultGW, StringComparison.InvariantCultureIgnoreCase))
                {
                    throw new VarFail(String.Format(
                        "'{0}' Service State : expect - '{1}', actual - '{2}'",
                        "IPAddress", verificationMap["DefaultGateway"], tmpDefaultGW));
                }
            }

            // Check Mask 
            if (verificationMap.ContainsKey("PrefixLength"))
            {
                string tmpPrefixLen = GetConfigVal("ifconfig " + interfaceName, "Mask", 1);
                if (!verificationMap["PrefixLength"].Equals(
                    tmpPrefixLen, StringComparison.InvariantCultureIgnoreCase))
                {
                    throw new VarFail(String.Format(
                        "'{0}' Service State : expect - '{1}', actual - '{2}'",
                        "IPAddress", verificationMap["PrefixLength"], tmpPrefixLen));
                }
            }
           
        }


        #region Private Methods

        private string GetConfigVal(string cmmd, string item, int step)
        {
            string reval = string.Empty;
            sshHelper.Execute(String.Format("{0}| grep 'inet addr' | awk -F'[ :]+' '{for (i=1;i<=NF;i){if({1} == $i) print $(i+{2})}}",cmmd, item, step), out reval);
            return reval.ToLower();
        }

        private string GetInitializeCmd(string initial, bool isDU)
        {
            StringBuilder command = new StringBuilder();
            StringBuilder config = new StringBuilder();
            Dictionary<string, string>initialDict = ConvertStringToPropMap(initial);
            string interf = string.Empty;
            if(!initialDict.ContainsKey("InterfaceName"))
            {
                interf = interfaceName;
            }
            else
            {
                interf = initialDict["InterfaceName"];
            }
            
            //set up the initial test environment if specified
            if(isDU)
            {
                if (initialDict.ContainsKey("IPAddress"))
                {
                    config.AppendLine(String.Format("address {0}", initialDict["IPAddress"]));
                }
                else
                {
                    throw new ArgumentException("Please specify IPAddress value for the initial test environment establishment! ");
                }
                if (initialDict.ContainsKey("BootProtocol"))
                {
                    string bootProto = "static";

                    //should consider about "bootp"?
                    if (initialDict["BootProtocol"] == "Automatic")
                    {
                        bootProto = "dhcp";
                    }
                    config.AppendLine(String.Format("iface {0} inet {1}", bootProto));
                }
                if (initialDict.ContainsKey("DefaultGateway"))
                {
                    config.AppendLine(String.Format("gateway {0}", initialDict["DefaultGateway"]));
                }
                if (initialDict.ContainsKey("PrefixLength"))
                {
                    config.AppendLine(String.Format("netmask {0}", initialDict["PrefixLength"]));
                }
                if (initialDict.ContainsKey("AddressFamily"))
                {
                    //TBD
                }
                string path = "/etc/sysconfig/network-scripts/ifcfg-" + interfaceName;
                command.Append(String.Format("mv {0} {0}-old; echo {1} > {0}; /etc/init.d/network restart", path, config.ToString()));
            }
            else
            {
                if (initialDict.ContainsKey("IPAddress"))
                {
                    config.AppendLine(String.Format("IPADDR={0}", initialDict["IPAddress"]));
                }
                else
                {
                    throw new ArgumentException("Please specify IPAddress value for the initial test environment establishment! ");
                }
                if (initialDict.ContainsKey("BootProtocol"))
                {
                    string bootProto = "static";
                    if (initialDict["BootProtocol"] == "Automatic")
                    {
                        bootProto = "dhcp";
                    }
                    config.AppendLine(String.Format("BOOTPROTO={0}", bootProto));
                }
                if (initialDict.ContainsKey("DefaultGateway"))
                {
                    config.AppendLine(String.Format("GATEWAY={0}", initialDict["DefaultGateway"]));
                }
                if (initialDict.ContainsKey("PrefixLength"))
                {
                    config.AppendLine(String.Format("NETMASK={0}", initialDict["PrefixLength"]));
                }
                if (initialDict.ContainsKey("AddressFamily"))
                {
                    //TBD
                }
                string path = "/etc/network/interfaces";
                command.Append(String.Format("mv {0} {0}-old; echo {1} > {0}; /etc/init.d/networking restart", path, config.ToString()));
            }
            return command.ToString();
        }

        private string GetFinalizeCmd(bool isDU)
        {
            string path = string.Empty;
            if (isDU)
            {
                path = "/etc/network/interfaces";
            }
            else 
            {
                path = "/etc/sysconfig/network-scripts/ifcfg-" + interfaceName;
            }
            return String.Format("rm -f {0}; mv {0}-old {0}", path);
        }

        #endregion
    }
}