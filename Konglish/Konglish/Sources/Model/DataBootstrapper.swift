//
//  DataBootstrapper.swift
//  Konglish
//
//  Created by 임영택 on 7/30/25.
//

import Foundation
import SwiftData
import os.log

struct DataBootstrapper {
    /// SwiftData 모델 컨텍스트. 주입이 필요하다
    private let context: ModelContext
    
    /// 카테고리 데이터셋 파일 이름
    private let categoriesFileName = "categories-20250730"
    
    /// 카드 데이터셋 파일 이름
    private let cardsFileName = "cards-20250730"
    
    /// 데이터셋 확장자
    private let fileExt = "json"
    
    private let logger = Logger.init(subsystem: Bundle.main.bundleIdentifier ?? "app.konglish.Konglish", category: "DataBootstrapper")
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    /// 부트스트랩을 진행한다
    func bootstrap() {
        guard let categories = loadData(type: [ImportedCategory].self, fileName: categoriesFileName, ext: fileExt),
           let cards = loadData(type: [ImportedCard].self, fileName: cardsFileName, ext: fileExt) else {
            logger.error("failed to load category and card json files")
            return
        }
        
        logger.info("started to bootstrap data")
        
        categories.forEach { categoryDTO in
            let categoryModel = mapToCategoryModel(category: categoryDTO)
            
            let levelModels = LevelType.allCases.map { levelType in
                let levelModel = LevelModel(levelNumber: levelType, category: categoryModel)
                categoryModel.levels.append(levelModel)
                return levelModel
            }
            
            let gameSessionModels = levelModels.map { levelModel in
                GameSessionModel(score: 0, level: levelModel)
            }
            
            context.insert(categoryModel)
            levelModels.forEach { context.insert($0) }
            gameSessionModels.forEach { context.insert($0) }
        }
        
        do {
            try context.save()
        } catch {
            logger.error("failed to save context after insert categories")
            fatalError()
        }
        
        cards.forEach { cardDTO in
            let model = mapToCardModel(card: cardDTO)
            context.insert(model)
        }
        
        do {
            try context.save()
        } catch {
            logger.error("failed to save context after insert cards")
            fatalError()
        }
        
        logger.info("bootstrap data completed!")
    }
    
    /// JSON 파일을 불러 배열로 반환한다
    private func loadData<T: Decodable>(type: T.Type, fileName: String, ext: String) -> T? {
        guard let fileLocation = Bundle.module.url(forResource: fileName, withExtension: ext) else { return nil }
        
        do {
            let data = try Data(contentsOf: fileLocation)
            return try JSONDecoder().decode(type, from: data)
        } catch {
            logger.error("json file load error")
            return nil
        }
    }
    
    /// 카테고리 DTO 구조체를 SwiftData 모델로 매핑한다
    private func mapToCategoryModel(category: ImportedCategory) -> CategoryModel {
        guard let id = UUID(uuidString: category.id) else {
            logger.error("category id is invalid uuid...")
            fatalError()
        }
        
        return CategoryModel(
            id: id,
            imageName: category.imageName,
            difficulty: category.difficulty,
            nameKor: category.nameKor,
            nameEng: category.nameEng
        )
    }
    
    /// 카드 DTO 구조체를 SwiftData 모델로 매핑한다
    private func mapToCardModel(card: ImportedCard) -> CardModel {
        guard let id = UUID(uuidString: card.id) else {
            logger.error("card id is invalid uuid...")
            fatalError()
        }
        
        guard let categoryId = UUID(uuidString: card.categoryId) else {
            logger.error("category id is invalid uuid...")
            fatalError()
        }
        
        let categoryDescription = FetchDescriptor<CategoryModel>(predicate: #Predicate{
            $0.id == categoryId
        })
        
        do {
            let categoryModelFetchResult = try context.fetch(categoryDescription)
            guard let categoryModel = categoryModelFetchResult.first else {
                logger.error("fetch result is empty... id=\(categoryId)")
                fatalError()
            }
            
            return CardModel(
                id: id,
                imageName: card.imageName,
                pronunciation: card.pronunciation,
                wordKor: card.wordKor,
                wordEng: card.wordEng,
                category: categoryModel
            )
        } catch {
            logger.error("no categoryModel")
            fatalError()
        }
    }
}

fileprivate struct ImportedCategory: Decodable {
    let id: String
    let imageName: String
    let difficulty: Int
    let nameKor: String
    let nameEng: String
}

fileprivate struct ImportedCard: Decodable {
    let id: String
    let categoryId: String
    let imageName: String
    let pronunciation: String
    let wordKor: String
    let wordEng: String
    let isBoss: Bool
}
