import HomeCareVoiceLogCore
import Testing

@Test("Simple category list keeps existing lightweight flow")
func simpleCategoriesMatchLegacyFlow() {
    #expect(CareCategory.simpleCases == [.medication, .meal, .toileting, .medicalVisit, .freeMemo])
}

@Test("Detailed category list includes expanded options")
func detailedCategoriesIncludeExpandedOptions() {
    #expect(CareCategory.detailedCases == [.medication, .meal, .toileting, .medicalVisit, .bathing, .vitalSigns, .exercise, .freeMemo])
}
