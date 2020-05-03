extends Area2D

var enemy = null

func can_see_player():
	return enemy != null

func _on_EnemyDetecor_body_entered(body):
#	enemy = body
	GameManager.detected_enemies += 1
	print(GameManager.detected_enemies)

func _on_EnemyDetecor_body_exited(body):
#	enemy = body
	GameManager.detected_enemies -= 1
	print(GameManager.detected_enemies)
