using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public class Gray : MonoBehaviour, IHittableObserver
{
    [SerializeField]
    private GameObject _player;
    private Player _playerScript;
    private Animator _anim;
    private Rigidbody _rb;
    private CapsuleCollider _cc;
    private LevelManager _lm;
    private NavMeshAgent _navMeshAgent;
    
    private bool _isWalkingSoundPlaying = false;
    private bool _isMoving;
    private bool _hasHitEffectActive = false;
    public float distanceToPlayer;
    public float pursueThreshold = 10f;
    public float disengageThreshold = 15f;
    public float attackThreshold = 2.5f;
    public float attackDisengageThreshold = 3f;
    public float attackWindup = 6f;
    public Coroutine attackCoroutine;
    public bool attacking = false;
    public bool pursue = false;
    public bool stun = false;
    public bool skillEMP = false;
    public bool awake = false;
    public int hp = 3;
    public bool hasObjective = false;
    private Vector3 _exitPos;

    private float nearestDoorDistance = 1000;
    private GameObject nearestDoor;
    private Vector3 nearestDoorVector = new Vector3(0, 0, 0);

    [SerializeField]
    private Material dissolveMaterial;
    private SkinnedMeshRenderer skinned;

    [SerializeField]
    private ParticleSystem _empAbility;

    [SerializeField]
    private ParticleSystem _hitEffect;

    [SerializeField]
    private ParticleSystem _deathEffect;
    private void Awake()
    {
        _anim = GetComponent<Animator>();
        _rb = GetComponent<Rigidbody>();
        _cc = GetComponent<CapsuleCollider>();
        _player = GameObject.Find("Player");
        _playerScript = _player.GetComponent<Player>();
        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        //_empAbility = GameObject.Find("EMPAbility").GetComponent<ParticleSystem>();
        //_isMoving = true;
        _empAbility.Stop();
        _deathEffect.Stop();
        _navMeshAgent = GetComponent<NavMeshAgent>();
        skinned = GetComponentInChildren<SkinnedMeshRenderer>();

        _lm.AddGray(this);

        Vector3 aux = _lm.allUfos[0].transform.position;
        _exitPos = new Vector3(aux.x, 0f, aux.z);
    }

    private void Start()
    {
        //for testing
        //Invoke("Die", 0.5f);
    }

    private void Update()
    {
        if (_player == null)
        {
            StopAllCoroutines();
            awake = false;
        }
        if (awake)
        {
            /*if (skillEMP)
            {
                _anim.SetBool("IsEMP", true);
            }
            else
            {*/
            //_anim.SetBool("IsEMP", false);
            if (!stun)
            {
                _anim.SetBool("IsStunned", false);
                distanceToPlayer = Vector3.Distance(_player.transform.position, transform.position);

                if (IsInSight() && !_lm.enemyHasObjective)
                {
                    if (CanAttack())
                    {
                        if (attackCoroutine == null) attackCoroutine = StartCoroutine("Attack");
                    }
                    else
                    {
                        if (attackCoroutine != null)
                        {
                            StopCoroutine(attackCoroutine);
                            attackCoroutine = null;
                            attacking = false;
                        }
                    }
                    pursue = true;

                    if (!_isWalkingSoundPlaying)
                        StartCoroutine(PlayGraySound());

                    //_anim.SetBool("IsWalking", true); Ahora en MovingAnimations()
                }
                else
                {
                    pursue = false;
                    _isWalkingSoundPlaying = false;
                    //_anim.SetBool("IsWalking", false); Ahora en MovingAnimations()
                }

                if(_isMoving)
                {
                    Move();
                }
                MovingAnimations();
                CheckPathStatus();

                if (!_lm.enemyHasObjective && Vector3.Distance(transform.position, _lm.objective.transform.position) < 3f)
                {
                    GrabObjective();
                    GameVars.Values.ShowNotification("The cat has been captured! You must prevent the grays getting to the ship!");
                }
                if (_lm.enemyHasObjective && Vector3.Distance(transform.position, _exitPos) < 3f)
                {
                    GoBackToShip();
                }
                if (hasObjective) MoveObjective();
            }
            else
            {
                pursue = false;
                _isWalkingSoundPlaying = false;
                _isMoving = false;
            }
            //}
        }
    }

    public void Move()
    {
        Vector3 dest = default(Vector3);
        if (pursue)
        {
            dest = _player.transform.position;
        }
        else if (_lm.enemyHasObjective) 
        {
            dest = _exitPos;
        }
        else if (_navMeshAgent.pathStatus == NavMeshPathStatus.PathPartial || _navMeshAgent.pathStatus == NavMeshPathStatus.PathInvalid)
        {
            //float nearestDoorDistance = 1000;
            //GameObject nearestDoor;
            //Vector3 nearestDoorVector = new Vector3(0, 0, 0);
            foreach(GameObject door in _lm.allDoors)
            {
                if(Vector3.Distance(transform.position, door.transform.position) < nearestDoorDistance)
                {
                    nearestDoorDistance = Vector3.Distance(transform.position, door.transform.position);
                    nearestDoor = door;
                    nearestDoorVector = door.transform.position;
                    dest = nearestDoor.transform.position;
                }

            }
            if(Vector3.Distance(transform.position, nearestDoorVector) < 3f)
            {
                nearestDoor.GetComponent<Door>().Interact();
            }
        }
        else
        {
            dest = _lm.objective.transform.position;
        }

        var dir = dest - transform.position;
        dir.y = 0f;
        //transform.forward = dir;
        _navMeshAgent.destination = dest;

        Debug.Log("voy hacia " + dest);
    }

    public void MovingAnimations()
    {
        if(_isMoving)
        _anim.SetBool("IsWalking", true);
        else
        _anim.SetBool("IsWalking", false);
    }

    public void CheckPathStatus()
    {
        if(_navMeshAgent.pathStatus == NavMeshPathStatus.PathPartial || _navMeshAgent.pathStatus == NavMeshPathStatus.PathInvalid)
        {
            //_isMoving = false;

        }
        else
        {
            _isMoving = true;
        }
    }

    public IEnumerator PlayGraySound()
    {
        GameVars.Values.soundManager.PlaySoundOnce("VoiceWhispering", 0.4f, true);
        yield return new WaitForSeconds(.01f);
        _isWalkingSoundPlaying = true;
    }

    public IEnumerator PlayGrayDeathSound()
    {
        GameVars.Values.soundManager.PlaySoundOnce("GrayDeathSound", 0.4f, true);
        yield return new WaitForSeconds(1.6f);
        GameVars.Values.soundManager.StopSound();
    }

   
    private bool IsInSight()
    {
        LayerMask layermask = 1 << 12;
        layermask = layermask << 3;
        if (Physics.Raycast(transform.position, _player.transform.position, disengageThreshold, layermask))
        {
            return false;
        }
        if (pursue)
        {
            if (distanceToPlayer > disengageThreshold) return false;
        }
        else
        {
            if (distanceToPlayer > pursueThreshold) return false;
        }
        return true;
    }

    private bool CanAttack()
    {
        if (!IsInSight()) return false;
        if (attacking)
        {
            if (distanceToPlayer > attackDisengageThreshold) return false;
        }
        else
        {
            if (distanceToPlayer > attackThreshold) return false;
        }
        return true;
    }

    IEnumerator Attack()
    {
        attacking = true;
        _anim.SetBool("IsEMP", true);
        yield return new WaitForSeconds(attackWindup);
        PlayParticleSystemShader();
        _playerScript.Damage();
        attacking = false;
        attackCoroutine = StartCoroutine("Attack");
        _anim.SetBool("IsEMP", false);
    }

    public void PlayParticleSystemShader()
    {
        _empAbility.Play();
    }

    public void Stun(float time)
    {
        _anim.SetBool("IsHitted", false);
        _rb.isKinematic = true;
        _isMoving = false;
        stun = true;
        _anim.SetBool("IsStunned", true);
        Invoke("UnStun", time);
    }

    public void SecondStun(float time)
    {
        _anim.SetBool("IsHitted", false);
        stun = true;
        _isMoving = false;
        _navMeshAgent.destination = transform.position;
        if (hasObjective)
        {
            DropObjective();
        }
        _anim.SetBool("IsStunned", true);
        _rb.isKinematic = true;
        Invoke("SecondUnStun", time);
    }

    public void UnStun()
    {
        _rb.isKinematic = false;
        stun = false;
        _isMoving = false;
    }

    public void SecondUnStun()
    {

        Vector3 dest = default(Vector3);
        if (pursue) dest = _player.transform.position;
        else if (_lm.enemyHasObjective) dest = _exitPos;
        else dest = _lm.objective.transform.position;
        _rb.isKinematic = false;
        stun = false;
        _isMoving = false;
    }

    public void SetPos(Vector3 pos)
    {
        transform.position = pos;
    }

    public void AwakeGray()
    {
        awake = true;
    }

    public void Damage()
    {
        Stun(0.2f);
        hp--;
        if (hp <= 0) Die();
    }

    public void GrabObjective()
    {
        hasObjective = true;
        GameVars.Values.TakeCat();
        _lm.CheckForObjective();
    }

    public void MoveObjective()
    {
        _lm.objective.transform.position = transform.position + new Vector3(0f, 2.8f, 0f);
    }

    public void DropObjective()
    {
        _lm.objective.transform.position = transform.position + new Vector3(0f, 0.75f, 0f);
        hasObjective = false;
        GameVars.Values.SetCatFree();
        _lm.CheckForObjective();
    }

    public void GoBackToShip()
    {
        if (hasObjective)
        {
            _lm.LoseGame();
            Destroy(_lm.objective);
        }
        _lm.RemoveGray(this);
        _lm.EnemyCameBack();
        Destroy(gameObject);
    }

    public void Die()
    {
        StartCoroutine(PlayGrayDeathSound());
        _navMeshAgent.destination = transform.position;
        if (hasObjective)
        {
            DropObjective();
        }
        awake = false;
        _rb.isKinematic = true;
        _cc.enabled = false;
        _anim.SetBool("IsDead", true);
        _lm.RemoveGray(this);
        _lm.CheckForObjective();

        var materials = skinned.sharedMaterials.ToList();
        materials.Add(dissolveMaterial);
        skinned.materials = materials.ToArray();

        _deathEffect.Play();
        LerpScaleDissolve(0.5f, 1f);
        Invoke("Dead", 3f);
    }

    public void Dead()
    {
        Destroy(gameObject);
    }

    public Vector3 GetVelocity()
    {
        return _navMeshAgent.velocity;
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, attackThreshold);
        Gizmos.DrawWireSphere(transform.position, attackDisengageThreshold);
        Gizmos.color = Color.white;
        Gizmos.DrawWireSphere(transform.position, pursueThreshold);
        Gizmos.DrawWireSphere(transform.position, disengageThreshold);
        Gizmos.DrawRay(transform.position, _player.transform.position - transform.position);
    }

    public void OnNotify(string message)
    {
        if (message.Equals("TennisBallHit"))
        {
            _anim.SetBool("IsHitted", true);
            StartCoroutine(PlayHitEffect(0.6f));
            GameVars.Values.soundManager.PlaySoundAtPoint("BallHit", transform.position, 0.45f);
            Damage();
            Stun(5f);
        }
    }

    IEnumerator PlayHitEffect(float timer)
    {
        _hitEffect.Play();
        _hasHitEffectActive = true;
        _hitEffect.gameObject.transform.GetComponentInChildren<Light>().enabled = _hasHitEffectActive;
        yield return new WaitForSeconds(timer);
        _hasHitEffectActive = false;
        _hitEffect.gameObject.transform.GetComponentInChildren<Light>().enabled = _hasHitEffectActive;
    }

    private float _valueToChange;
    IEnumerator LerpScaleDissolve(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            dissolveMaterial.SetFloat("ScaleDissolve", _valueToChange);
            yield return null;
        }


        _valueToChange = endValue;
    }
}
