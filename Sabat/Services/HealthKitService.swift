import Foundation
import HealthKit

enum HealthKitServiceError: LocalizedError {
    case unavailable
    case missingEndDate

    var errorDescription: String? {
        switch self {
        case .unavailable:
            "Health data is unavailable on this device."
        case .missingEndDate:
            "The sleep session must be closed before saving to Health."
        }
    }
}

actor HealthKitService {
    private let store = HKHealthStore()

    private var sleepType: HKCategoryType {
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    }

    func requestAuthorizationIfAvailable() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitServiceError.unavailable
        }

        let shareTypes: Set<HKSampleType> = [sleepType]
        let readTypes: Set<HKObjectType> = [sleepType]
        try await store.requestAuthorization(toShare: shareTypes, read: readTypes)
    }

    func save(session: SleepSession) async throws {
        guard let endedAt = session.endedAt else {
            throw HealthKitServiceError.missingEndDate
        }

        let timeZoneName = TimeZone.current.identifier
        let metadata: [String: Any] = [
            HKMetadataKeyTimeZone: timeZoneName,
        ]

        var samples = [HKCategorySample(
            type: sleepType,
            value: HKCategoryValueSleepAnalysis.inBed.rawValue,
            start: session.startedAt,
            end: endedAt,
            metadata: metadata
        )]

        samples.append(contentsOf: session.phaseSamples.map { sample in
            HKCategorySample(
                type: sleepType,
                value: sample.phase.healthKitValue.rawValue,
                start: sample.startDate,
                end: sample.endDate,
                metadata: metadata
            )
        })

        try await store.save(samples)
    }
}

private extension SleepPhase {
    var healthKitValue: HKCategoryValueSleepAnalysis {
        switch self {
        case .awake:
            .awake
        case .light:
            .asleepCore
        case .deep:
            .asleepDeep
        case .rem:
            .asleepREM
        }
    }
}
