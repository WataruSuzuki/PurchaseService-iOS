//
//  UIViewController+Transition.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/09/24.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialBottomSheet
import MaterialComponents.MaterialAppBar

extension UIViewController {
    @objc func tapDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func presentBottomSheet(viewController: UICollectionViewController) {
        // Initialize the bottom sheet with the view controller just created
        let container = MDCAppBarContainerViewController.init(contentViewController: viewController)
        container.preferredContentSize = CGSize(width: 500, height: self.view.frame.height / 2)
        container.appBarViewController.headerView.trackingScrollView = viewController.collectionView
        container.isTopLayoutGuideAdjustmentEnabled = true
        
        //let colorScheme = MDCSemanticColorScheme()
        //colorScheme.primaryColor = MDCPalette.lightBlue.tint500
        //colorScheme.primaryColorVariant = MDCPalette.lightBlue.tint400
        //colorScheme.secondaryColor = colorScheme.primaryColor
        //MDCAppBarColorThemer.applyColorScheme(colorScheme, to: container.appBarViewController)
        
        let bottomSheet = MDCBottomSheetController(contentViewController: container)
        MDCBottomSheetControllerShapeThemer.applyShapeScheme(MDCShapeScheme(), to: bottomSheet)
        
        let shapeGenerator = MDCRectangleShapeGenerator()
        let cornerTreatment = MDCRoundedCornerTreatment(radius: 16)
        shapeGenerator.topLeftCorner = cornerTreatment
        shapeGenerator.topRightCorner = cornerTreatment
        bottomSheet.setShapeGenerator(shapeGenerator, for: .preferred)
        
        bottomSheet.trackingScrollView = viewController.collectionView;
        // Present the bottom sheet
        present(bottomSheet, animated: true, completion: nil)
    }
    
    var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar || false
    }
}
