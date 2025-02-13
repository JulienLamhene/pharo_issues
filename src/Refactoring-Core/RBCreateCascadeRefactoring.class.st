"
I am  a refactoring used to generate cascades in source code.

Two or more message sends to the same object are replaced by a cascaded message send. It expects a selection of the messages and the receiver variable.

"
Class {
	#name : 'RBCreateCascadeRefactoring',
	#superclass : 'RBMethodRefactoring',
	#instVars : [
		'selector',
		'selectedInterval',
		'parseTree',
		'sequenceNode',
		'statementNodes',
		'transformedNode'
	],
	#category : 'Refactoring-Core-Refactorings-Unused',
	#package : 'Refactoring-Core',
	#tag : 'Refactorings-Unused'
}

{ #category : 'instance creation' }
RBCreateCascadeRefactoring class >> combine: anInterval from: aSelector in: aClass [
	^ self new
		combine: anInterval from: aSelector in: aClass;
		yourself
]

{ #category : 'instance creation' }
RBCreateCascadeRefactoring class >> model: aNamespace combine: anInterval from: aSelector in: aClass [
	^ self new
		model: aNamespace;
		combine: anInterval from: aSelector in: aClass;
		yourself
]

{ #category : 'preconditions' }
RBCreateCascadeRefactoring >> addStatementNode: aNode [
	aNode isMessage
		ifTrue: [ ^ statementNodes add: aNode ].
	aNode isCascade
		ifTrue: [ ^ statementNodes addAll: aNode messages ].
	self refactoringError: aNode formattedCode , ' is not a valid message'
]

{ #category : 'preconditions' }
RBCreateCascadeRefactoring >> applicabilityPreconditions [

	^ {
		  (RBCondition definesSelector: selector in: class).
		  (RBCondition withBlock: [
			   self
				   findSequenceNode;
				   findStatementNodes.
			   true ]) }
]

{ #category : 'preconditions' }
RBCreateCascadeRefactoring >> breakingChangePreconditions [

	^ { (RBCondition withBlock: [
		   self findReceiverNode.
		   true ]) }
]

{ #category : 'initialization' }
RBCreateCascadeRefactoring >> combine: anInterval from: aSelector in: aClass [
	class := self classObjectFor: aClass.
	selector := aSelector.
	selectedInterval := anInterval
]

{ #category : 'transforming' }
RBCreateCascadeRefactoring >> combineMessages [
	"This combines the messages and adds the assignements of the last statement to the cascade. This is not necessary if there is a return, because the refactoring engine automatically compensates for that."

	| expression |
	transformedNode := RBCascadeNode messages: (statementNodes
		collect: [ :each | each copy ]).
	expression := statementNodes last parent.
	[ expression isAssignment ] whileTrue: [
		transformedNode := RBAssignmentNode
			variable: expression variable
			value: transformedNode.
		expression := expression parent ]
]

{ #category : 'transforming' }
RBCreateCascadeRefactoring >> compileCode [
	class compileTree: (self parseTreeRewriterClass
		replaceStatements: sequenceNode formattedCode
		with: transformedNode formattedCode
		in: self parseTree
		onInterval: selectedInterval)
]

{ #category : 'preconditions' }
RBCreateCascadeRefactoring >> findReceiverNode [
	"Find the sequence to be combined."

	| receiverNodes |
	receiverNodes := statementNodes
		collect: [ :each | each receiver ].
	receiverNodes asSet size = 1
		ifFalse: [ self refactoringError: 'All statements must have the same receiver' ].
	(receiverNodes first isLiteralNode or: [ receiverNodes first isVariable ])
		ifFalse: [ self refactoringWarning: 'The receiver is an expression. Proceed with caution' ]
]

{ #category : 'preconditions' }
RBCreateCascadeRefactoring >> findSequenceNode [
	"Find the sequence to be combined."

	sequenceNode := self parserClass
		parseExpression: self selectedSource
		onError: [ :msg :pos | self refactoringError: 'Invalid source to rewrite' ].
	(sequenceNode isSequence and: [ sequenceNode statements size > 1 ])
		ifFalse: [ self refactoringError: 'You must select two or more statements' ]
]

{ #category : 'preconditions' }
RBCreateCascadeRefactoring >> findStatementNodes [
	"Find the sequence to be combined."

	statementNodes := OrderedCollection new.
	sequenceNode statements do: [ :each |
		(sequenceNode isLast: each)
			ifFalse: [ self addStatementNode: each ]
			ifTrue: [
				| current |
				current := each.
				[ current isReturn or: [ current isAssignment ] ]
					whileTrue: [ current := current value ].
				self addStatementNode: current ] ]
]

{ #category : 'accessing' }
RBCreateCascadeRefactoring >> parseTree [

	parseTree
		ifNil: [ parseTree := class parseTreeForSelector: selector.
			parseTree ifNil: [ self refactoringError: 'Could not parse sources' ]
			].
	^ parseTree doSemanticAnalysis
]

{ #category : 'preconditions' }
RBCreateCascadeRefactoring >> preconditions [

	^ self applicabilityPreconditions & self breakingChangePreconditions
]

{ #category : 'transforming' }
RBCreateCascadeRefactoring >> privateTransform [
	self combineMessages.
	self compileCode
]

{ #category : 'accessing' }
RBCreateCascadeRefactoring >> selectedSource [
	^  self parseTree source copyFrom: selectedInterval first to: selectedInterval last
]
