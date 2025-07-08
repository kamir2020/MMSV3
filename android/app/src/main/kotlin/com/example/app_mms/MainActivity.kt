package com.example.app_mms

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.app_mms/usb"
    private val ACTION_USB_PERMISSION = "com.example.app_mms.USB_PERMISSION"
    private var permissionResultCallback: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "requestUsbPermission") {
                permissionResultCallback = result
                requestUsbPermission()
            } else {
                result.notImplemented()
            }
        }
    }

    private fun requestUsbPermission() {
        val usbManager = getSystemService(Context.USB_SERVICE) as UsbManager
        val deviceList = usbManager.deviceList.values

        if (deviceList.isEmpty()) {
            println("❌ No USB devices connected")
            permissionResultCallback?.error("NO_DEVICE", "No USB devices found", null)
            return
        }

        for (device in deviceList) {
            println("🔍 Device found: ${device.deviceName}, VID=${device.vendorId}, PID=${device.productId}")
            if (device.vendorId == 4292 && device.productId == 60000) { // CP2102N
                if (usbManager.hasPermission(device)) {
                    println("✅ Already has permission for ${device.deviceName}")
                    permissionResultCallback?.success(true)
                    return
                }

                val permissionIntent = PendingIntent.getBroadcast(
                    this,
                    0,
                    Intent(ACTION_USB_PERMISSION),
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
                )

                println("🔐 Requesting permission for ${device.deviceName}")
                usbManager.requestPermission(device, permissionIntent)
                return
            }
        }

        println("❌ CP2102N device not found (VID: 4292, PID: 60000)")
        permissionResultCallback?.error("DEVICE_NOT_FOUND", "CP2102N not found", null)
    }

    companion object {
        var flutterCallback: MethodChannel.Result? = null
        fun onPermissionResult(granted: Boolean) {
            flutterCallback?.apply {
                if (granted) success(true)
                else error("PERMISSION_DENIED", "User denied USB permission", null)
            }
            flutterCallback = null
        }
    }
}
