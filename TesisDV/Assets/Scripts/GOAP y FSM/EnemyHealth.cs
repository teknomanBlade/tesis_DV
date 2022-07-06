using System.Globalization;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.AI;

public class EnemyHealth : MonoBehaviour, IHittableObserver, IGridEntity
{
    public int hp = 3;
    public bool dead = false;
    private NavMeshAgent _navMeshAgent;
    public Vector3 Position
    {
        get => transform.position;
        set => transform.position = value;
    }

    public event Action<IGridEntity> OnMove;

    void Awake()
    {
        _navMeshAgent = GetComponent<NavMeshAgent>();
    }

    public void TakeDamage(int dmgAmount)
    {
        hp -= dmgAmount;
        if (hp <= 0)
        dead = true;
        Die();
    }

    public void SetPosition(Vector3 newPos)
    {
        Position = newPos;
    }

    public void OnNotify(string message)
    {
        if (message.Equals("RacketHit"))
        {          
            GameVars.Values.soundManager.PlaySoundAtPoint("BallHit", transform.position, 0.45f);
            TakeDamage(1);  
        }
        if (message.Equals("TennisBallHit"))
        {
            GameVars.Values.soundManager.PlaySoundAtPoint("BallHit", transform.position, 0.45f);
            TakeDamage(3);
        }
    }

    private void Die()
    {
        Destroy(this.gameObject);
    }

    public Vector3 GetVelocity()
    {
        return _navMeshAgent.velocity;
    }

    
}
