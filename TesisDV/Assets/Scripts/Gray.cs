//using System.Numerics;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public class Gray : MonoBehaviour, IHittableObserver, IPlayerDamageObservable
{
    private List<IPlayerDamageObserver> _myObserversPlayerDamage = new List<IPlayerDamageObserver>();
    [SerializeField]
    private GameObject _player;
    private Player _playerScript;
    private AudioSource _as;
    [SerializeField]
    private Animator _anim;
    private Rigidbody _rb;
    private CapsuleCollider _cc;
    private LevelManager _lm;
    private NavMeshAgent _navMeshAgent;
    
    private bool _isWalkingSoundPlaying = false;
    private bool _isMoving;
    private bool _hasHitEffectActive = false;
    private float _attackWindup = 1f;
    public float distanceToPlayer;
    public float pursueThreshold = 10f;
    public float disengageThreshold = 15f;
    public float attackThreshold = 2.5f;
    public float attackDisengageThreshold = 3f;
    
    public Coroutine attackCoroutine;
    public bool dead = false;
    public bool attacking = false;
    public bool pursue = false;
    public bool stun = false;
    public bool skillEMP = false;
    public bool awake = false;
    public int hp = 3;
    public bool hasObjective = false;
    private Vector3 _exitPos;

    private float nearestDoorDistance = 1000;
    private Transform nearestDoor;
    private Vector3 nearestDoorVector;

    /*[SerializeField]
    private Material deathMaterial;*/

    [SerializeField]
    private Material dissolveMaterial;
    [SerializeField]
    private Material sphereEffectMaterial;

    private SkinnedMeshRenderer skinned;
    private float _valueToChange;

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
        _as = GetComponent<AudioSource>();
        _player = GameVars.Values.Player.gameObject;
        _playerScript = GameVars.Values.Player;
        AddObserver(_playerScript);
        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        //_empAbility = GameObject.Find("EMPAbility").GetComponent<ParticleSystem>();
        //_isMoving = true;
        _empAbility.Stop();
        _deathEffect.Stop();
        _navMeshAgent = GetComponent<NavMeshAgent>();
        skinned = GetComponentInChildren<SkinnedMeshRenderer>();
        nearestDoorDistance = 1000;
        _lm.AddGray(this);

        //Exit pos lo setea el UFO en el instantiate.
       /*  Vector3 aux = _lm.allUfos[0].transform.position;
        _exitPos = new Vector3(aux.x, 0f, aux.z); */
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
        else if (_lm.allDoorsAreClosed)
        {
            //float nearestDoorDistance = 1000;
            //GameObject nearestDoor;
            //Vector3 nearestDoorVector = new Vector3(0, 0, 0);

            StartCoroutine(FindClosestDoor());
            
            dest = nearestDoor.position;
            if (Vector3.Distance(transform.position, nearestDoorVector) < 3f)
            {
                _anim.SetBool("IsAttacking", true);
                
                nearestDoor.GetComponent<AuxDoor>().Interact();
                GameVars.Values.ShowNotification("The Grays have entered through the " + nearestDoor.GetComponent<AuxDoor>().myDoor.itemName);
                StartCoroutine(LerpOutlineWidthAndColor(8f,2f, Color.red));
                _lm.ChangeDoorsStatus();
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

        //Debug.Log("voy hacia " + dest);
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
        GameVars.Values.soundManager.PlaySoundOnce(_as,"VoiceWhispering", 0.4f, true);
        yield return new WaitForSeconds(.01f);
        _isWalkingSoundPlaying = true;
    }

    public IEnumerator PlayGrayDeathSound()
    {
         _anim.SetBool("IsDead", true);
        SwitchDissolveMaterial(dissolveMaterial);
        GameVars.Values.soundManager.PlaySoundOnce(_as, "GrayDeathSound", 0.4f, true);
        yield return new WaitForSeconds(1.6f);
        GameVars.Values.soundManager.StopSound();
        yield return new WaitForSeconds(2.5f);
        yield return StartCoroutine(LerpScaleDissolve(0f, 1.5f)); 
        Dead();
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
    public void SwitchDissolveMaterial(Material material)
    {
        var materials = skinned.sharedMaterials.ToList();
        materials.Clear();
        materials.Add(material);
        skinned.sharedMaterials = materials.ToArray();
    }
    IEnumerator Attack()
    {
        attacking = true;
        _isMoving = false;
        _anim.SetBool("IsAttacking", true);
        yield return new WaitForSeconds(_attackWindup);
        TriggerPlayerDamage("DamagePlayer");
        PlayParticleSystemShader();
        attacking = false;
        _isMoving = true;
        //attackCoroutine = StartCoroutine("Attack");
        _anim.SetBool("IsAttacking", false);
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
        _anim.SetBool("IsGrab", true);
        GameVars.Values.TakeCat(_exitPos);
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
        //_lm.EnemyCameBack();
        Destroy(gameObject);
    }

    public void Die()
    {
        dead = true;
        var spawnPos = new Vector3(transform.position.x, transform.position.y + 8f, transform.position.z);
        var UFO = GameVars.Values.LevelManager.UFOsPool.GetObject().InitializePosition(spawnPos);
        StartCoroutine(PlayGrayDeathSound());
        _navMeshAgent.destination = transform.position;
        if (hasObjective)
        {
            DropObjective();
        }
        awake = false;
        _rb.isKinematic = true;
        _cc.enabled = false;
        
        _lm.RemoveGray(this);
        _lm.CheckForObjective();
    }

    public void PlayShaderDissolve()
    {
        
    }

    public void PlayPostDeath()
    {
        _anim.SetBool("IsPostDeath", true);
        //StartCoroutine(LerpScaleDissolve(0f, 1f));
    }

    public void Dead()
    {
        dissolveMaterial.SetFloat("_ScaleDissolveGray", 1);
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
            ActiveInnerEffect();
            StartCoroutine(LerpSphereHitEffect(2f,2f));
            GameVars.Values.soundManager.PlaySoundAtPoint("BallHit", transform.position, 0.45f);
            Damage();
            Stun(5f);
        }
        else if (message.Equals("RacketHit"))
        {
            if (_anim)
            {
                _anim.SetBool("IsHitted", true);
                ActiveInnerEffect();
                StartCoroutine(LerpSphereHitEffect(2f, 2f));
                GameVars.Values.soundManager.PlaySoundAtPoint("BallHit", transform.position, 0.45f);
                Damage();
                Stun(5f);
            }
        }
    }

    public void ActiveInnerEffect()
    {
        _hitEffect.Play();
        _hasHitEffectActive = true;
        var meshRenderer = _hitEffect.gameObject.transform.GetComponentInChildren<MeshRenderer>();
        meshRenderer.enabled = _hasHitEffectActive;
        sphereEffectMaterial = meshRenderer.sharedMaterials.FirstOrDefault();
    }

    IEnumerator FindClosestDoor()
    {
        nearestDoorDistance = 1000f;

        foreach (Transform door in _lm.allDoors)
        {
            if (Vector3.Distance(transform.position, door.position) < nearestDoorDistance)
            {
                nearestDoorDistance = Vector3.Distance(transform.position, door.position);
                nearestDoor = door;
                nearestDoorVector = door.position;

            }

        }
        yield return new WaitForSeconds(0.5f);
    }

    IEnumerator LerpSphereHitEffect(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            sphereEffectMaterial.SetFloat("_Interpolator", _valueToChange);
            yield return null;
        }

        _valueToChange = endValue;
        yield return new WaitForSeconds(1.5f);
        sphereEffectMaterial.SetFloat("_Interpolator", 0);
        _hasHitEffectActive = false;
        _hitEffect.gameObject.transform.GetComponentInChildren<MeshRenderer>().enabled = _hasHitEffectActive;
    }

    IEnumerator LerpScaleDissolve(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            dissolveMaterial.SetFloat("_ScaleDissolveGray", _valueToChange);
            yield return null;
        }

        _valueToChange = endValue;
    }
    IEnumerator LerpOutlineWidthAndColor(float endValue, float duration, Color color)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            nearestDoor.GetComponent<AuxDoor>().myDoor.GetComponent<Outline>().OutlineColor = color;
            nearestDoor.GetComponent<AuxDoor>().myDoor.GetComponent<Outline>().OutlineWidth = _valueToChange;
            yield return null;
        }

        _valueToChange = endValue;
        yield return StartCoroutine(LerpOutlineWidthAndColor(0f, 2f, Color.red));
        yield return new WaitForSeconds(0.5f);
        yield return StartCoroutine(LerpOutlineWidthAndColor(0f, 2f, Color.green));
    }
    public Gray SetExitUFO(Vector3 exitPosition)
    {
        Vector3 aux = exitPosition;
        _exitPos = new Vector3(aux.x, 0f, aux.z);
        
        return this;
    }

    public void AddObserver(IPlayerDamageObserver obs)
    {
        _myObserversPlayerDamage.Add(obs);
    }

    public void RemoveObserver(IPlayerDamageObserver obs)
    {
        if (_myObserversPlayerDamage.Contains(obs)) _myObserversPlayerDamage.Remove(obs);
    }

    public void TriggerPlayerDamage(string triggerMessage)
    {
        _myObserversPlayerDamage.ForEach(x => x.OnNotifyPlayerDamage(triggerMessage));
    }
}
