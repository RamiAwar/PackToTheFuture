extends Area2D

var enemy = null

func can_see_player():
	return enemy != null

func _on_EnemyDetecor_body_entered(body):
#	enemy = body
	GameManager.detected_enemies += 1


func _on_EnemyDetecor_body_exited(body):
#	enemy = body
	GameManager.detected_enemies -= 1
