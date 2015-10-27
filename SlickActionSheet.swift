//
//  SlickActionSheet.swift
//  MiniChatViews
//
//  Created by Dondrey Taylor on 10/26/15.
//  Copyright © 2015 Convo, Inc. All rights reserved.
//

import UIKit

class SlickActionSheet: UIView {
    
    // Internals
    var actionBtnText:[String]!
    var actionBtns:[UIButton]!
    var actionBtnCallbacks:[()->Void]!
    var isVisible:Bool = false
    
    // UI Components
    var overlay:UIView!
    var actionSheet:UIView!
    
    // Configuration
    var configBtnFont:UIFont! = UIFont.systemFontOfSize(18)
    var configBtnFontColor:UIColor! = UIColor.grayColor()
    var configBtnHeight:CGFloat! = 60
    var configBtnBackgroundColor:UIColor! = UIColor.lightGrayColor()
    var configBtnVerticalSpacing:CGFloat! = 15
    var configBtnVerticalBottomSpacing:CGFloat = 25
    var configBtnHorziontalSpacing:CGFloat! = 10
    var configBtnBorderColor:UIColor! = UIColor.grayColor()
    var configBtnCornerRadius:CGFloat = 5
    var configBtnCustomStyleHandler:((index:Int, text:String, button:UIButton)->UIButton)?
    var configBtnEnableCancel:Bool = true
    var configCloseBtnText:String = "Cancel"
    var configCloseBtnCustomStyleHandler:((text:String, button:UIButton)->UIButton)?
    var configSheetOpenDuration:Double! = 0.2
    var configSheetCloseDuration:Double! = 0.2
    var configOverlayBackgroundColor:UIColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
    var configSheetCloseOnBtnTap:Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    func initView() {
        actionBtns = []
        actionBtnText   = []
        actionBtnCallbacks  = []
    }
    
    func addAction(text:String, onTap: ()->Void) {
        actionBtnText.append(text)
        actionBtnCallbacks.append(onTap)
    }
    
    func onTap(button: UIButton) {
        if configSheetCloseOnBtnTap {
            dismiss()
        }
        actionBtnCallbacks[button.tag]()
    }
    
    func show() {
        if !isVisible {
            render()
        }
    }
    
    func dismiss() {
        if isVisible {
            UIView.animateWithDuration(configSheetCloseDuration, animations: { () -> Void in
                    self.overlay.alpha = 0
                    self.actionSheet.frame.origin.y = self.frame.height
                }, completion: { (finished) -> Void in
                    self.isVisible = false
                    self.overlay.removeFromSuperview()
                    self.actionSheet.removeFromSuperview()
            })
        }
    }
    
    func render() {
        
        actionSheet = UIView()
        actionSheet.frame = CGRectMake(0, frame.height, frame.width, configBtnHeight * CGFloat(actionBtnText.count+(configBtnEnableCancel ? 1 : 0)) + (configBtnEnableCancel ? configBtnVerticalSpacing : 0))
        
        overlay   = UIView()
        overlay.frame = bounds
        overlay.backgroundColor = configOverlayBackgroundColor
        overlay.alpha = 0
        overlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismiss"))
        
        let actionSheetBtnHolder = UIView()
        actionSheetBtnHolder.frame = CGRectMake(0,0,frame.width-(2*configBtnHorziontalSpacing),(configBtnHeight * CGFloat(actionBtnText.count)))
        actionSheetBtnHolder.frame.origin.x = actionSheet.frame.width/2 - actionSheetBtnHolder.frame.width/2
        actionSheetBtnHolder.clipsToBounds = true
        actionSheetBtnHolder.layer.cornerRadius = configBtnCornerRadius
        actionSheet.addSubview(actionSheetBtnHolder)
        
        
        let closeBtn = UIButton()
        closeBtn.setAttributedTitle(NSAttributedString(string: configCloseBtnText, attributes: [
            NSFontAttributeName: configBtnFont,
            NSForegroundColorAttributeName: configBtnFontColor
        ]), forState: UIControlState.Normal)
        closeBtn.backgroundColor = configBtnBackgroundColor
        closeBtn.layer.cornerRadius = configBtnCornerRadius
        
        if configCloseBtnCustomStyleHandler != nil {
            configCloseBtnCustomStyleHandler!(text:configCloseBtnText, button:closeBtn)
        }
        
        closeBtn.frame.size.width = frame.width-(2*configBtnHorziontalSpacing)
        closeBtn.frame.size.height = configBtnHeight
        closeBtn.frame.origin.x = actionSheet.frame.width/2 - closeBtn.frame.width/2
        closeBtn.frame.origin.y = actionSheetBtnHolder.frame.height + configBtnVerticalSpacing
        closeBtn.addTarget(self, action: "dismiss", forControlEvents: UIControlEvents.TouchUpInside)
        
        if configBtnEnableCancel {
            actionSheet.addSubview(closeBtn)
        }
        
        for (index, text) in actionBtnText.enumerate() {
            
            var actionBtn = UIButton()
            
            actionBtn.backgroundColor = configBtnBackgroundColor
            actionBtn.setAttributedTitle(NSAttributedString(string: text, attributes: [
                NSFontAttributeName: configBtnFont,
                NSForegroundColorAttributeName: configBtnFontColor
                ]), forState: UIControlState.Normal)
            
            if configBtnCustomStyleHandler != nil {
                actionBtn = configBtnCustomStyleHandler!(index: index, text: text, button:actionBtn)
            }
            
            actionBtn.tag = index
            actionBtn.frame.size.width = actionSheetBtnHolder.frame.width
            actionBtn.frame.size.height = configBtnHeight
            actionBtn.frame.origin.y = CGFloat(index) * configBtnHeight
            actionBtn.addTarget(self, action: "onTap:", forControlEvents: UIControlEvents.TouchUpInside)
            actionSheetBtnHolder.addSubview(actionBtn)
            actionBtns.append(actionBtn)
            
            if index != actionBtnText.count-1 {
                actionBtn.layer.addSublayer(getBorder(configBtnBorderColor.CGColor, y:actionBtn.frame.height-1, width: actionBtn.frame.width))
            }
        }
        
        addSubview(overlay)
        addSubview(actionSheet)
        
        UIView.animateWithDuration(configSheetOpenDuration, animations: { () -> Void in
                self.overlay.alpha = 1
                self.actionSheet.frame.origin.y = self.frame.height - (self.actionSheet.frame.height + self.configBtnVerticalBottomSpacing)
            }, completion: { (finished) -> Void in
                self.isVisible = true
        })
    }
    
    func getBorder(color:CGColor, y:CGFloat, width:CGFloat) -> CALayer {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0,y,width,1)
        bottomBorder.backgroundColor = color
        return bottomBorder
    }
}





