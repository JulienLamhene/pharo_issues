"
Replaces isNil ifTrue , isNil ifFalse and isNil ifTrue:ifFalse by ifNil: , ifNotNil and ifNil:ifNotNil: to make the code more readable. Helps to avoid unnecesary temporal variables.
"
Class {
	#name : 'ReIsNilAndConditionalRule',
	#superclass : 'ReNodeRewriteRule',
	#category : 'General-Rules-Coding Idiom Violation',
	#package : 'General-Rules',
	#tag : 'Coding Idiom Violation'
}

{ #category : 'accessing' }
ReIsNilAndConditionalRule class >> group [

	^ 'Coding Idiom Violation'
]

{ #category : 'accessing' }
ReIsNilAndConditionalRule class >> rationale [

	^ 'Using specific conditional methods leads to shorter code and helps in avoiding unneeded temporary variables.<n><n>Replaces<n><t>isNil ifTrue: ~~> ifNil:<n><t>isNil ifFalse: ~~> ifNotNil:<n><t>isNil ifTrue:ifFalse ~~> ifNil:ifNotNil:'
		expandMacros
]

{ #category : 'accessing' }
ReIsNilAndConditionalRule class >> ruleName [
	^ 'Sends isNil and a conditional check instead of using #ifNil: #ifNotNil: or #ifNil:ifNotNil:'
]

{ #category : 'initialization' }
ReIsNilAndConditionalRule >> initialize [

	super initialize.
	self
		replace: '``@receiver isNil ifFalse: ``@notNilBlock' with: '``@receiver ifNotNil: ``@notNilBlock';
		replace: '``@receiver isNil ifTrue: ``@nilBlock' with: '``@receiver ifNil: ``@nilBlock';
		replace: '``@receiver isNil ifTrue: ``@nilBlock ifFalse: ``@notNilBlock'
			with: '``@receiver ifNil: ``@nilBlock ifNotNil: ``@notNilBlock';
		replace: '``@receiver isNil ifFalse: ``@notNilBlock ifTrue: ``@nilBlock'
			with: '``@receiver ifNil: ``@nilBlock ifNotNil: ``@notNilBlock'
]
