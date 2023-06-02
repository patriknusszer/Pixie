//
//  ViewController.swift
//  Pixie
//
//  Created by Patrik Nusszer on 12/03/17.
//  Copyright © 2017 Patrik Nusszer. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var txt_coord_x: NSTextField!
    @IBOutlet var txt_coord_y: NSTextField!
    @IBOutlet var cw_color: NSColorWell!
    @IBOutlet var txt_color_hex: NSTextField!
    @IBOutlet var txt_color_css: NSTextField!
    
    @IBOutlet var txt_r: NSTextField!
    @IBOutlet var txt_g: NSTextField!
    @IBOutlet var txt_b: NSTextField!
    
    @IBOutlet var txt_r_norm: NSTextField!
    @IBOutlet var txt_g_norm: NSTextField!
    @IBOutlet var txt_b_norm: NSTextField!
    
    @IBOutlet var txt_color_hex_cmyk: NSTextField!
    @IBOutlet var txt_c: NSTextField!
    @IBOutlet var txt_m: NSTextField!
    @IBOutlet var txt_y: NSTextField!
    @IBOutlet var txt_k: NSTextField!
    
    @IBOutlet var txt_c_norm: NSTextField!
    @IBOutlet var txt_m_norm: NSTextField!
    @IBOutlet var txt_y_norm: NSTextField!
    @IBOutlet var txt_k_norm: NSTextField!
    
    @IBOutlet var txt_go_x: NSTextField!
    @IBOutlet var txt_go_y: NSTextField!
    @IBOutlet var btn_grab_color: NSButton!
    var mouseLeftDownHooksActive: Bool =  false;
    var globalMouseMovedHookEvent: Any?;
    var localMouseMovedHookEvent: Any?;
    var globalMouseLeftDownHookEvent: Any?
    var localMouseLeftDownHookEvent: Any?
    
    
    @IBAction func go_to_pos_ui(sender: AnyObject) {
        if (!txt_go_x.stringValue.isEmpty && !txt_go_y.stringValue.isEmpty) {
            CGWarpMouseCursorPosition(CGPoint(x: Int(txt_go_x.intValue), y: Int(txt_go_y.intValue)))
            update_ui()
        }
    }
    
    @IBAction func grab_color_ui(sender: AnyObject) {
        if (!mouseLeftDownHooksActive) {
            mouseLeftDownHooksActive = true;
            setMouseLeftDownHooks()
            btn_grab_color.isEnabled = false;
            btn_grab_color.title = "Click to grab"
        }
        else {
            mouseLeftDownHooksActive = false;
            btn_grab_color.title = "Grab color"
            setMouseMovedHooks()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMouseMovedHooks()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func setMouseMovedHooks() {
        globalMouseMovedHookEvent = NSEvent.addGlobalMonitorForEvents(matching: NSEvent.EventTypeMask.mouseMoved, handler: globalMouseMoveHook)
        localMouseMovedHookEvent = NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.mouseMoved, handler: localMouseMoveHook)
    }
    
    func unSetMouseMovedHooks() {
        NSEvent.removeMonitor(globalMouseMovedHookEvent!)
        NSEvent.removeMonitor(localMouseMovedHookEvent!)
    }
    
    func setMouseLeftDownHooks() {
        globalMouseLeftDownHookEvent = NSEvent.addGlobalMonitorForEvents(matching: NSEvent.EventTypeMask.leftMouseDown, handler: globalMouseLeftDownHook)
        localMouseLeftDownHookEvent = NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.leftMouseDown, handler: localMouseLeftDownHook)
    }
    
    func unSetMouseLeftDownHooks() {
        NSEvent.removeMonitor(globalMouseLeftDownHookEvent!)
        NSEvent.removeMonitor(localMouseLeftDownHookEvent!)
    }
    
    func nsptReverseY(pt: NSPoint) -> NSPoint {
        let new_y = (NSScreen.main?.frame.size.height)! - pt.y
        let new_pt = NSPoint(x: pt.x, y: new_y)
        return new_pt
    }
    
    func getColorAt(coords: NSPoint) -> NSColor {
        let image = CGDisplayCreateImage(CGMainDisplayID(), rect: CGRect(origin: CGPoint(x: Int(coords.x), y: Int(coords.y)), size: CGSize(width: 1, height: 1)))!
        let bitmap = NSBitmapImageRep(cgImage: image)
        let color = bitmap.colorAt(x: 0, y: 0)!
        return color
    }
    
    func globalMouseMoveHook(e: NSEvent) {
        update_ui()
    }
    
    func localMouseMoveHook(e: NSEvent) -> NSEvent {
        update_ui()
        return e
    }
    
    func globalMouseLeftDownHook(e: NSEvent) {
        grabbed_color_ui()
    }
    
    func localMouseLeftDownHook(e: NSEvent) -> NSEvent {
        grabbed_color_ui()
        return e
    }
    
    func grabbed_color_ui() {
        unSetMouseMovedHooks()
        unSetMouseLeftDownHooks()
        btn_grab_color.title = "Press to continue"
        btn_grab_color.isEnabled = true;
    }
    
    func update_ui() {
        let coords = nsptReverseY(pt: NSEvent.mouseLocation)
        txt_coord_x.intValue = Int32(coords.x)
        txt_coord_y.intValue = Int32(coords.y)
        var color = getColorAt(coords: coords)
        cw_color.color = color
        color = color.usingColorSpace(NSColorSpace.genericRGB)!
        let r = Float(color.redComponent) * Float(255.99999)
        let g = Float(color.greenComponent) * Float(255.99999)
        let b = Float(color.blueComponent) * Float(255.99999)
        txt_r.stringValue = String(Int(r))
        txt_g.stringValue = String(Int(g))
        txt_b.stringValue = String(Int(b))
        
        txt_r_norm.stringValue = String(round(Double(r) / 255 * 10000) / 10000)
        txt_g_norm.stringValue = String(round(Double(g) / 255 * 10000) / 10000)
        txt_b_norm.stringValue = String(round(Double(b) / 255 * 10000) / 10000)
        
        let r_s = String(format: "%02X", Int32(r))
        let g_s = String(format: "%02X", Int32(g))
        let b_s = String(format: "%02X", Int32(b))
        txt_color_hex.stringValue = "#" + r_s + g_s + b_s
        txt_color_css.stringValue = String(format: "rgb(%d, %d, %d)", Int32(r), Int32(g), Int32(b))
        color = color.usingColorSpace(NSColorSpace.genericCMYK)!
        let c = Float(color.cyanComponent) * Float(255.99999)
        let m = Float(color.magentaComponent) * Float(255.99999)
        let y = Float(color.yellowComponent) * Float(255.99999)
        let k = Float(color.blackComponent) * Float(255.99999)
        txt_c.stringValue = String(Int(c))
        txt_m.stringValue = String(Int(m))
        txt_y.stringValue = String(Int(y))
        txt_k.stringValue = String(Int(k))
        
        txt_c_norm.stringValue = String(Double(c) / 255)
        txt_m_norm.stringValue = String(Double(m) / 255)
        txt_y_norm.stringValue = String(Double(y) / 255)
        txt_k_norm.stringValue = String(Double(k) / 255)
        
        let c_s = String(format: "%02X", Int32(c))
        let m_s = String(format: "%02X", Int32(m))
        let y_s = String(format: "%02X", Int32(y))
        let k_s = String(format: "%02X", Int32(k))
        txt_color_hex_cmyk.stringValue = "#" + c_s + m_s + y_s + k_s
    }
}

