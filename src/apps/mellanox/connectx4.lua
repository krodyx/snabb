
--- Device driver for the Mellanox ConnectX-4 series Ethernet controller.

module(...,package.seeall)

local ffi      = require "ffi"
local C        = ffi.C
local lib      = require("core.lib")
local pci      = require("lib.hardware.pci")
local register = require("lib.hardware.register")
local index_set = require("lib.index_set")
local macaddress = require("lib.macaddress")
local mib = require("lib.ipc.shmem.mib")
local timer = require("core.timer")

ConnectX4 = {}
ConnectX4.__index = ConnectX4

function ConnectX4:new(arg)
   local conf = config.parse_app_arg(arg)
   local self = setmetatable({}, self)

   local pciaddress = conf.pciaddress

   pci.unbind_device_from_linux(pciaddress)
   pci.set_bus_master(pciaddress, true)
   local base, fd = pci.map_pci_memory(pciaddress, 0)

   --[[
   register.define(config_registers_desc, self.r, self.base)
   register.define(transmit_registers_desc, self.r, self.base)
   register.define(receive_registers_desc, self.r, self.base)
   register.define_array(packet_filter_desc, self.r, self.base)
   register.define(statistics_registers_desc, self.s, self.base)
   register.define_array(queue_statistics_registers_desc, self.qs, self.base)
   self.txpackets = ffi.new("struct packet *[?]", num_descriptors)
   self.rxpackets = ffi.new("struct packet *[?]", num_descriptors)
   return self:init()
   ]]

   return self
end


function selftest()
   local pcidev1 = lib.getenv("SNABB_PCI_CONNECTX40") or lib.getenv("SNABB_PCI0")
   local pcidev2 = lib.getenv("SNABB_PCI_CONNECTX41") or lib.getenv("SNABB_PCI1")
   if not pcidev1
      or pci.device_info(pcidev1).driver ~= 'apps.mellanox.connectx4'
      or not pcidev2
      or pci.device_info(pcidev2).driver ~= 'apps.mellanox.connectx4'
   then
      print("SNABB_PCI_CONNECTX4[0|1]/SNABB_PCI[0|1] not set or not suitable.")
      os.exit(engine.test_skipped_code)
   end

   local device_info_1 = pci.device_info(pcidev1)
   local device_info_2 = pci.device_info(pcidev2)

   print(device_info_1.model)

   local app1 = ConnectX4:new{pciaddress = pcidev1}
   local app2 = ConnectX4:new{pciaddress = pcidev2}


end
