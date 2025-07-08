package com.example.app_mms

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager

class UsbPermissionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "com.example.app_mms.USB_PERMISSION") {
            val device: UsbDevice? = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
            val granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)

            if (device != null) {
                println("📡 Received permission result for ${device.deviceName}: ${if (granted) "GRANTED" else "DENIED"}")
            } else {
                println("⚠️ No device in USB permission intent")
            }

            MainActivity.onPermissionResult(granted)
        }
    }
}
