//
// Created by Mengyu Li on 2020/3/16.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

extension String {
    init?(cString: UnsafePointer<CChar>?) {
        guard let c = cString else { return nil }
        self = String(cString: c)
    }
}
